local hookutils=require'ultimate-autopair.hook.utils'
local putils=require'ultimate-autopair.profile.pair.utils'
---@class ua.prof.pair.cr:ua.object
---@field get_pairs fun():ua.prof.pair.pair[]
---@class ua.prof.pair.cr.conf:ua.prof.pair.map.conf

local M={}
---@param o ua.info
---@return ua.actions|nil
function M.run(o)
    if o.source.mode=='c' then return end
    local conf={}
    local m=o.m --[[@as ua.prof.pair.cr]]
    local spairs=putils.backwards_get_start_pairs(o,m.get_pairs())
    for _,p in ipairs(spairs) do
        local opair=setmetatable({m=p},{__index=o})
        if o.lines[o.row]:sub(o.col,o.col+#p.end_pair_old-1)==p.end_pair_old
            and putils.run_end_pair_filter(opair)
            --and putils.pair_balansed_start(opair) --Not needed: it doesn't modify the pairs
        then
            return {
                '\n',
                {'pos',o.col,o.row},
                '\n',
            }
        end
    end
    if conf.do_nothing_if_fail then return {} end
end
---@param objects ua.instance
---@param conf ua.prof.pair.cr.conf
---@return ua.prof.pair.cr
function M.init(objects,conf)
    --TODO: each pair may have it's own newline config defined
    ---@type ua.prof.pair.cr
    return putils.create_obj(conf,{
        run=M.run,
        get_pairs=function () return putils.get_pairs(objects) end,
        doc='autopairs newline',
    })
end
return M
