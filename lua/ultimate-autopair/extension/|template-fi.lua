local M={}
---@param m prof.def.module
---@param ext prof.def.ext
function M.call(m,ext)
    local conf=ext.conf
    local filter=m.filter
    m.filter=function(o)
        return filter(o)
    end
end
return M
