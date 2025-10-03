local utils=require'ultimate-autopair.utils'
---@param conf ua.config.filter.escape
return function (conf)
    ---@type ua.config.filter.spec
    return {
        pos=function (con,range)
            return vim.api.nvim_strwidth(utils.line_before_range(con,range):match('\\*$'))%2==1
        end,
        _name='escape',_conf=conf,

        filter=conf.filter,
        filter_or=conf.filter_or,
        singlechar=conf.singlechar,
    }
end
