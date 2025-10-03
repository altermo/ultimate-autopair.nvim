local utils=require'ultimate-autopair.utils'
---@param conf ua.config.filter.cmdtype
return function (conf)
    ---@type ua.config.filter.spec
    return {
        once=function (con)
            return con.bufnr==nil and utils.in_list(conf.skip,vim.fn.getcmdtype())
        end,

        --TODO?: set these from the conf.lua instead, to avoid hard to find bugs
        _name='cmdtype',_conf=conf,

        filter=conf.filter,
        filter_or=conf.filter_or,
        singlechar=conf.singlechar,
    }
end
