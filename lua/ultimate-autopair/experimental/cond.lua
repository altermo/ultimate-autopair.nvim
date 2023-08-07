local M={}
local utils=require'ultimate-autopair.utils'
M.fns={
    in_string=function(o,conf)
        local str_ext=require'ultimate-autopair.extensions.string'
        local cache=(o.save[str_ext.save_type] or {}).cache
        return str_ext.instring(o,cache,conf or {})
    end,
    in_lisp=function(o,conf)
        if vim.o.lisp then return true end
        if (conf or {}).notree then return end
        local ft=M.fns.get_injected_ft(o)
        return vim.filetype.get_option(ft,'lisp')
    end,
    get_injected_ft=function(o)
        if o.incmd then return vim.o.filetype end
        return utils.getsmartft(o.linenr-1,o.col-1,o.save)
    end,
}
function M.call(m,ext)
    if not m.conf.cond then return end
    local cond=type(m.conf.cond)=='function' and {m.conf.cond} or m.conf.cond
    local check=m.check
    m.check=function(o)
        for _,v in ipairs(cond or {}) do
            if not v(o,m,M.fns) then
                return
            end
        end
        for _,v in ipairs(ext.conf.cond or {}) do
            if not v(o,m,M.fns) then
                return
            end
        end
        return check(o)
    end
    --TODO: add filter
end
return M
