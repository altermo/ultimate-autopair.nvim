---@class ua.filter.filetype.state
---@field range Range4?
--- They are one after another, in order (so optimizations can be made)
---@field exclude_ranges Range4[]?

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
---@param conf ua.config.filter.filetype
return function (conf)
    ---@type ua.filter.filetype.state
    local state={}
    ---@type ua.config.filter.spec
    return {
        once=function (con)
            if not conf.treesitter or not utils.treesitter_enabled() then
                return ft_excluded(conf,con.root_filetype),true
            end
        end,
        pos=function (con,range,is_iter)
            if not is_iter then
                return ft_excluded(conf,ft_on_range(conf,con,range))
            end
            error'TODO'
        end,
        on_iter=function (con,range)
            error'TODO'
        end,
        _name='filetype',_conf=conf,

        filter=conf.filter,
        filter_or=conf.filter_or,
        singlechar=conf.singlechar,
    }
end
