local M={}
local default=require'ultimate-autopair.profile.default.utils'
local utils=require'ultimate-autopair.utils'
---@param _ prof.cond.conf
---@param mem core.module[]
function M.init(_,mem)
    local m={}
    m.doc='ultimate-autopair , map'
    m.p=10
    m.check=function (o)
        if o.mode=='i' and o.key==',' and
            utils.getsmartft(o)=='lua' and
            o.line:sub(o.col-1,o.col-1)=='{' then
            local pair,col,row=default.get_pair_and_end_pair_pos_from_start(o,o.col,true)
            if not pair then return end
            local node=utils.gettsnode(utils._get_o_pos(o,o.col-1))
            if node and node:type()~='table_constructor' then return end
            return utils.create_act{
                {'j',row-o.row },{'home'},
                {'l',col},
                ',',
                {'k',row-o.row},{'home'},
                {'l',o.col-1},
            }
        end
    end
    m.get_map=function (mode) if mode=='i' then return {','} end end
    table.insert(mem,m)
end
return M
