---A
local M={}
local default=require'ultimate-autopair.profile.default.utils'
local utils=require'ultimate-autopair.utils'
---@param o core.o
---@param m prof.def.m.pair
function M.check(o,m)
    if not m.conf.dosuround then return end
    local pair,index,rindex=default.get_pair_and_end_pair_pos_from_start(o,o.col,nil,function (pair)
        return pair.conf.suround
    end)
    if not pair or rindex~=o.row then return end
    if not m.fn.can_check_pre(o) then return end
    if m.fn.find_corresponding_pair(o,o.col-#m.pair+1) then return end
    local num=index-o.col+#pair.end_pair
    return utils.create_act({
        m.pair:sub(-1),
        {'l',num},
        m.end_pair,
        {'h',num+#m.end_pair}
    },o)
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
