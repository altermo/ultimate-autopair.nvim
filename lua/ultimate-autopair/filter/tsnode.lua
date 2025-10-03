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
---@return vim.treesitter.Query[]
local function get_queries_for_parser(conf,tslang)
    --TODO: how to do cache which only is invalidated when the config changes

    --TODO: what if a node is separate and exclude or inclusive and not inclusive?

    local queries={}

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

        local captures={}
        for i,j in pairs(query_tbl) do
            table.insert(captures,('(%s) @%s'):format(i,j:gsub('_','.')))
        end
        table.insert(queries,vim.treesitter.query.parse(tslang,table.concat(captures,'\n')))
    end

    for _,query in ipairs(conf.query) do
        if query.lang==tslang then
            table.insert(queries,query)
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

    local captures={}
    for i,j in pairs(query_tbl) do
        table.insert(captures,('(%s) @%s'):format(i,j))
    end
    table.insert(queries,vim.treesitter.query.parse(tslang,table.concat(captures,'\n')))

    return queries
end

---@param conf ua.config.filter.tsnode
return function (conf)
    ---@type ua.config.filter.spec
    return {
        once=function (con)
            return nil,not utils.treesitter_enabled()
        end,
        pos=function (con,range,is_iter)
            if not is_iter then
                local ltree=utils.get_langtree(con,range)
                if not ltree then return false end

                --TODO: the nodes are only inclusive one way, but range_in_range can only be enabled for both ways

                --TODO: temp
                local queries=get_queries_for_parser(conf,ltree:lang())
                for _,query in ipairs(queries) do
                    for id,node in query:iter_captures(ltree:trees()[1]:root(), range[1], range[3]) do
                        local name=query.captures[id]
                        local match=vim.treesitter.get_node_text(node,ltree:source())
                        local t,st=unpack(vim.split(name,'.',{plain=true}))
                        if t=='separate' then
                        elseif st~='inclusive' and st~=nil then
                            if utils.range_in_range({node:range()},range,(function ()
                                for _,pattern in pairs(querieslib.inclusive_pattern[st]) do
                                    if vim.startswith(match,pattern) then return 'right' end
                                end
                            end)()) then
                                return true
                            end
                        else
                            if utils.range_in_range({node:range()},range,st=='inclusive' and 'right') then
                                return true
                            end
                        end
                    end
                end
                return false
            end
            error'TODO'
        end,
        on_iter=function (con,range)
            error'TODO'
        end,
        _name='tsnode',_conf=conf,

        filter=conf.filter,
        filter_or=conf.filter_or,
        singlechar=conf.singlechar,
    }
end
