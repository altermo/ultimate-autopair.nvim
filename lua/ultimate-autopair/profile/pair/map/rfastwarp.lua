local putils=require'ultimate-autopair.profile.pair.utils'

local M={}
---@type (fun(o:ua.info,ind:number,p:string,first:boolean):ua.actions|nil)[]
M.act={
    function (o,ind,p,first)
        if first then return end
        if not o.line:sub(ind-1,ind-1):match('[%w_]') then return end
        if o.line:sub(ind,ind):match('[%w_]') then return end
        return {
            {'delete',0,p},
            {'pos',ind},
            p,{'left',p},
        }
    end,
    function (o,ind,p,first)
        if first then return end
        local prev_spairs=putils.backwards_get_end_pairs(o,o.m.get_pairs())
        if #prev_spairs==0 then return end
        return {
            {'delete',0,p},
            {'pos',ind},
            p,{'left',p},
        }
    end,
    function (o,_,p,first)
        if not first then return end
        local prev_spairs=putils.backwards_get_end_pairs(o,o.m.get_pairs())
        if #prev_spairs==0 then return end
        for _,v in ipairs(prev_spairs) do
            local opair=setmetatable({m=v,col=o.col-1},{__index=o})
            local col,row=putils.prev_open_start_pair(opair)
            if row and col then
                return {
                    {'delete',0,p},
                    {'pos',col,row},
                    p,{'left',p},
                }
            end

        end
    end,
    function (o,ind,p)
        local prev_spairs=putils.backwards_get_start_pairs(o,o.m.get_pairs())
        if #prev_spairs==0 then return end
        return {
            {'delete',0,p},
            {'pos',ind},
            p,{'left',p},
        }
    end
}
---@param o ua.info
---@return ua.actions|nil
function M.run(o,_rec)
    local m=o.m --[[@as ua.prof.pair.fastwarp]]
    local spairs=(_rec or m.nocursormove==false) and {} or putils.backwards_get_start_pairs(o,m.get_pairs())
    for _,spair in ipairs(spairs) do
        local opair=setmetatable({m=spair},{__index=o})
        local col,row=putils.next_open_end_pair(opair)
        if col and row
            --and putils.pair_balansed_start(opair) --Not needed: it doesn't modify the pairs distribution
        then
            local act=M.run(setmetatable({col=col,row=row},{__index=o}),true)
            if act then
                table.insert(act,1,{'pos',col,row})
                table.insert(act,{'pos',o.col,o.row})
                return act
            end
        end
    end
    local epairs=putils.forward_get_end_pairs(o,m.get_pairs())
    for _,epair in ipairs(epairs) do
        for col=o.col,1,-1 do
            for _,v in ipairs(M.act) do
                local ret=v(setmetatable({col=col},{__index=o}),col,epair.end_pair_old,col==o.col)
                if ret then return ret end
            end
        end
        if o.col~=1 then
            return {
                {'delete',0,epair.end_pair_old},
                {'pos',1},
                epair.end_pair_old,
                {'left',epair.end_pair_old},
            }
        else
            if o.row==1 then return {} end
            return {
                {'delete',0,epair.end_pair_old},
                {'pos',#o.lines[o.row>1 and o.row-1 or 1]+1,o.row-1},
                epair.end_pair_old,
                {'left',epair.end_pair_old},
            }
        end
    end
end

---@param objects ua.instance
---@param conf ua.prof.pair.fastwarp.conf
---@return ua.prof.pair.fastwarp
function M.init(objects,conf)
    --TODO: each pair may have it's own fastwarp config defined
    ---@type ua.prof.pair.fastwarp
    return putils.create_obj(setmetatable({map=conf.rmap},{__index=conf}),{
        run=M.run,
        get_pairs=function () return putils.get_pairs(objects) end,
        nocursormove=conf.nocursormove,
        doc='autopairs reverse fastwarp',
    })
end
return M
