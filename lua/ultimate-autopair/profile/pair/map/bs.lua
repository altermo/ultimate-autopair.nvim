local putils=require'ultimate-autopair.profile.pair.utils'
---@class ua.prof.pair.bs:ua.object
---@field get_pairs fun():ua.prof.pair.pair[]
---@field conf ua.prof.pair.bs.conf
---@class ua.prof.pair.bs.conf:ua.prof.pair.map.conf
---@field overjump boolean
---@field do_nothing_if_fail boolean

local M={}
---@param o ua.info
---@return ua.actions|nil
function M.run(o)
    local m=o.m --[[@as ua.prof.pair.bs]]
    local spairs=putils.backwards_get_start_pairs(o,m.get_pairs())
    for _,p in ipairs(spairs) do
        local opair=setmetatable({m=p},{__index=o})
        --TODO: speedup: if text after cursor is pair then run quickly
        local col,row=putils.next_open_end_pair(opair)
        if col and row
            and putils.pair_balansed_start(opair)
            and (putils.get_opt(m.conf.overjump,o,p) or (o.col==col and o.row==row))
        then
            return {
                {'pos',col,row},
                {'delete',0,#p.end_pair_old},
                {'pos',o.col,o.row},
                {'delete',#p.start_pair_old},
            }
        end
    end
    local epairs=putils.backwards_get_end_pairs(o,m.get_pairs())
    for _,p in ipairs(epairs) do
        local opair=setmetatable({m=p},{__index=o})
        if o.line:sub(o.col-#p.end_pair_old-#p.start_pair_old,o.col-#p.end_pair_old-1)==p.start_pair_old
            and putils.run_start_pair_filter(setmetatable({col=o.col-#p.end_pair_old-#p.start_pair_old},{__index=opair}))
            and putils.pair_balansed_end(opair)
        then
            return {{'delete',#p.start_pair_old+#p.end_pair_old}}
        end
    end
    if m.conf.do_nothing_if_fail then return {} end
end
---@param objects ua.instance
---@param conf ua.prof.pair.bs.conf
---@return ua.prof.pair.bs
function M.init(objects,conf)
    --TODO: each pair may have it's own backspace config defined
    ---@type ua.prof.pair.bs
    return putils.create_obj(conf,{
        conf=conf,
        run=M.run,
        get_pairs=function () return putils.get_pairs(objects) end,
        doc='autopairs backspace',
    })
end
return M
