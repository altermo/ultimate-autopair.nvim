local M={}
local default=require'ultimate-autopair.configs.default.utils'
function M.call(m,ext)
    local exte=default.prepare_extensions(ext.conf.ext)
    local nm=vim.deepcopy(m)
    nm._type=m._type
    ---@diagnostic disable-next-line: duplicate-set-field
    nm.check=function (_) end
    nm.rule=function () return true end
    default.init_extensions(nm,exte)
    local check=m.check
    m.check=function (o)
        if not nm.rule() then return check(o) end
        local ret=nm.check(vim.deepcopy(o))
        if ret then return ret end
        return check(o)
    end
end
return M
