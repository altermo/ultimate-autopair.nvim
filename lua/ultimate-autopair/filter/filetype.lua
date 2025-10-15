local utils=require'ultimate-autopair.utils'
---@param conf ua.config.filter.filetype
---@param con ua.context
---@param range Range4
---@return string
local function ft_on_range(conf,con,range)
    if conf.treesitter==false then
        return con.root_filetype
    end
    return utils.get_filetype(con,range)
end
---@param conf ua.config.filter.filetype
---@param ft string
---@return boolean
local function ft_excluded(conf,ft)
    if conf.ft and next(conf.ft --[[@as table]]) then
        if not utils.in_list(conf.ft,ft) then
            return true
        end
    end
    return conf.nft and utils.in_list(conf.nft,ft) or false
end

---@param con ua.context
---@param range Range4
---@return Range4[]?
local function trees_to_ranges(con,range)
    local trange,ltree=utils.get_tstree_range(con,range)
    if not ltree then return end

    local ranges={}
    if trange then
        table.insert(ranges,{0,0,trange[1],trange[2]})
    end

    for _,child in pairs(ltree:children()) do
        for _,tree_ in ipairs(child:trees()) do
            for _,trange_ in ipairs(tree_:included_ranges(false)) do
                utils.insert_range(ranges,trange_)
            end
        end
    end

    if trange then
        utils.insert_range(ranges,{trange[3],trange[4],math.huge,math.huge})
    end

    return ranges
end

---@param conf ua.config.filter.filetype
return function (conf)

    ---@class ua.filter.filetype.state
    ---@field ranges Range4[]?
    ---@field idx number?
    ---@field backwards boolean?
    local state

    ---@type ua.config.filter.spec
    return {
        once=function (con)
            state={}
            if not conf.treesitter or not con.treesitter_enabled then
                state.skip=true
                return ft_excluded(conf,con.root_filetype)
            end
        end,
        pos=function (con,range,is_iter)
            if state.skip then return end
            if not is_iter then
                return ft_excluded(conf,ft_on_range(conf,con,range))
            end
            if not state.ranges then
                return false
            end

            --TODO: optimize
            for _,i in ipairs(state.ranges) do
                if utils.range_in_range(i,range,'both') then
                    return true
                end
            end
        end,
        on_iter=function (con,range,type_)
            if state.skip then return end
            if not conf.injectlang_separate then
                return
            end
            --TODO: what if `range` is not the same...
            -- check that the smallest tree is still the same, and if not find the new smallest tree
            if not state.ranges then
                state.ranges=trees_to_ranges(con,range)

                if state.ranges==nil then return end
            end
            if type_=='reverse' then
                state.idx=#state.ranges
                state.backwards=true
            else
                state.idx=1
                state.backwards=false
            end
        end,
        _name='filetype',_conf=conf,

        filter=conf.filter,
        filter_or=conf.filter_or,
        singlechar=conf.singlechar,
    }
end
