---A
---@class ext.suround.pconf:prof.def.conf.pair
---@field dosuround? boolean|fun(...:prof.def.optfn):boolean?
---@field suround? boolean|fun(...:prof.def.optfn):boolean?

local M={}
local default=require'ultimate-autopair.profile.default.utils'
local open_pair=require'ultimate-autopair.profile.default.utils.open_pair'
local utils=require'ultimate-autopair.utils'
---@param o core.o
---@param m prof.def.m.pair
function M.check(o,m)
    local pconf=m.conf
    ---@cast pconf ext.suround.pconf
    if not default.orof(pconf.dosuround,o,m,true) then return end
    local pair,index,rindex=default.get_pair_and_end_pair_pos_from_start(o,o.col,nil,function (pair)
        return default.orof(pair.conf.suround,o,m,true)
    end)
    if not pair or (not pair.multiline and rindex~=o.row) then return end
    if not m.fn.can_check_pre(o) then return end
    if open_pair.open_end_pair_after(m,o,o.col-#m.pair+1) then return end
    return utils.create_act({
        m.pair:sub(-1),
        {'j',rindex-o.row},{'home'},
        {'l',index+#pair.end_pair},
        m.end_pair,
        {'k',rindex-o.row},{'home'},
        {'l',o.col}
    })
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
