---A
local M={}
local default=require'ultimate-autopair.profile.default.utils'
local utils=require'ultimate-autopair.utils'
---@param o core.o
---@param m prof.def.m.pair
function M.check(o,m)
    if not m.conf.dosuround then return end
    local pair=default.start_pair(o.col,o,true,function (p)
        return p.conf.suround
    end)
    if not pair then return end
    local index=pair.fn.find_end_pair(o,o.col+#pair.pair)
    if index and m.fn.check_start_pair(o,o.col) then
        return m.pair:sub(-1)..utils.addafter(index-o.col+#pair.pair-1,m.end_pair)
    end
end
---@param m prof.def.module
---@param _ prof.def.ext
function M.call(m,_)
    if not default.get_type_opt(m,{'start'}) then return end
    ---@cast m prof.def.m.pair
    local check=m.check
    m.check=function (o)
        local ret=M.check(o,m)
        if ret then return ret end
        return check(o)
    end
end
return M
