local querieslib=require'ultimate-autopair.queries'
local utils=require'ultimate-autopair.utils'

---@param nodetypes table<string,any>
---@param tslang string
local function filter_invalid_node_types(nodetypes,tslang)
    for node,_ in pairs(nodetypes) do
        if pcall(vim.treesitter.query.parse,tslang,('(%s)'):format(node)) then
        else
            nodetypes[node]=nil
        end
    end
end

---@param conf ua.config.filter.tsnode
---@param tslang string
---@return vim.treesitter.Query
local function get_query_for_tslang(conf,tslang)
    --TODO: how to do cache which only is invalidated when the config changes

    --TODO: what if a node is separate and exclude or inclusive and not inclusive?

    local captures={}

    for _,type_ in pairs({
        'exclude',
        'separate',
        'exclude_inclusive',
        'separate_inclusive',
    }) do
        local query_tbl={}
        for _,i in ipairs(conf[type_] --[[@as table]]) do
            query_tbl[i]=type_
        end

        ---TODO: add note to docs about how this is using tslang instead of filetype

        filter_invalid_node_types(query_tbl,tslang)

        for _,i in ipairs(conf[type_][tslang] or {}) do
            query_tbl[i]=type_
        end

        for i,j in pairs(query_tbl) do
            table.insert(captures,('(%s) @%s'):format(i,j:gsub('_','.')))
        end
    end

    local query_tbl={}
    for nodeclass in pairs(querieslib.nodes) do
        local c=conf.nodeclass_filter[nodeclass]
        if c==nil then c=conf.nodeclass_filter[true] end
        if c then
            query_tbl[nodeclass]=('%s.%s'):format(c,nodeclass)
        end
    end

    filter_invalid_node_types(query_tbl,tslang)

    for i,j in pairs(query_tbl) do
        table.insert(captures,('(%s) @%s'):format(i,j))
    end

    if conf.query[tslang] then
        table.insert(captures,conf.query[tslang])
    end

    return vim.treesitter.query.parse(tslang,table.concat(captures,'\n'))
end

---@param conf ua.config.filter.tsnode
---@param parser vim.treesitter.LanguageTree
---@param range Range4
---@return 'separate'|'exclude'?
---@return Range4?
local function range_in_queries(conf,parser,range)
    --TODO: cache (or just save it in state)

    local type_,smallest

    parser:for_each_tree(function (tree,ltree)
        local query=get_query_for_tslang(conf,ltree:lang())
        for id,node in query:iter_captures(tree:root(),range[1],range[3]) do
            local name=query.captures[id]
            local match=vim.treesitter.get_node_text(node,ltree:source())
            local t,st=unpack(vim.split(name,'.',{plain=true}))
            local inclusive
            if st=='inclusive' then
                inclusive='right'
            elseif querieslib.inclusive_pattern[st] then
                for _,pattern in pairs(querieslib.inclusive_pattern[st]) do
                    if vim.startswith(match,pattern) then
                        inclusive='right'
                        break
                    end
                end
            end
            local node_range={node:range()}
            if not utils.range_in_range(node_range,range,inclusive) then
            elseif t=='separate' then
                type_='separate'
                if smallest==nil or utils.range_in_range(smallest,node_range,'both') then
                    smallest=node_range
                end
            elseif t=='exclude' then
                type_='exclude'
                smallest=nil
                return
            end
        end
    end)
    return type_,smallest
end

---@param conf ua.config.filter.tsnode
---@param range Range4
---@param parser vim.treesitter.LanguageTree
---@return Range4[]
local function queries_to_ranges(conf,parser,range)
    local type_,qrange=range_in_queries(conf,parser,range)
    assert(type_~='exclude' and qrange)

    local ranges={}
    if qrange then
        table.insert(ranges,{0,0,qrange[1],qrange[2]})
    end

    local start=qrange and qrange[1] or 1
    local end_=qrange and qrange[3] or -1

    parser:for_each_tree(function (tree,ltree)
        local query=get_query_for_tslang(conf,ltree:lang())
        for id,node in query:iter_captures(tree:root(),start,end_) do
            local name=query.captures[id]
            local match=vim.treesitter.get_node_text(node,ltree:source())
            local t,st=unpack(vim.split(name,'.',{plain=true}))
            local inclusive
            if st=='inclusive' then
                inclusive='right'
            elseif querieslib.inclusive_pattern[st] then
                for _,pattern in pairs(querieslib.inclusive_pattern[st]) do
                    if vim.startswith(match,pattern) then
                        inclusive='right'
                        break
                    end
                end
            end
            local node_range={node:range()}
            if not utils.range_in_range(node_range,range,inclusive) then
            elseif t=='separate' or t=='separate' then
                --TODO what are we supposed to do here?:
                -- `ranges` needs to be a ordered list of ranges
                -- but there's no guarantee that the trees are ordered
            end
        end
    end)

    if qrange then
        table.insert(ranges,{qrange[3],qrange[4],math.huge,math.huge})
    end
    return ranges
end

---@param conf ua.config.filter.tsnode
return function (conf)

    ---@class ua.filter.tsnode.state
    ---@field ranges Range4?
    ---@field idx number?
    ---@field backwards boolean?
    local state={}

    ---@type ua.config.filter.spec
    return {
        once=function (con)
            return nil,not utils.treesitter_enabled()
        end,
        pos=function (con,range,is_iter)
            if not is_iter then
                local parser=utils.get_parser(con)
                if not parser then return false end

                if range_in_queries(conf,parser,range)=='exclude' then
                    return true
                end
                return false
            end
            error'TODO'
        end,
        on_iter=function (con,range,type_)
            if not state.ranges then
                local parser=utils.get_parser(con)
                if not parser then return false end

                state.ranges=queries_to_ranges(conf,parser,range)
            end
            if type_=='reverse' then
                state.idx=#state.ranges
                state.backwards=true
            else
                state.idx=1
                state.backwards=false
            end
        end,
        _name='tsnode',_conf=conf,

        filter=conf.filter,
        filter_or=conf.filter_or,
        singlechar=conf.singlechar,
    }
end
