local M={}
---@param m prof.def.module
---@param ext prof.def.ext
function M.call(m,ext)
    local conf=ext.conf
    local check=m.check
    m.check=function (o)
        local ret=M.check(o,m,ext)
        if ret then return ret end
        return check(o)
    end
end
return M
