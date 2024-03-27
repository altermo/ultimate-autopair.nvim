local hookutils=require'ultimate-autopair.hook.utils'
local putils=require'ultimate-autopair.profile.pair.utils'
---@class ua.prof.def.cr.info
---@field pairs ua.prof.def.pair[]
---@class ua.prof.def.cr:ua.object
---@field info ua.prof.def.cr.info
---@class ua.prof.def.cr.conf:ua.prof.def.map

local M={}
---@param o ua.info
---@return ua.actions|nil
function M.run(o)
    if o.source.mode=='c' then return end
    local m=o.m --[[@as ua.prof.def.cr]]
    local info=m.info
    local spairs=putils.backwards_get_start_pairs(o,info.pairs)
    for _,p in ipairs(spairs) do
        local opair=setmetatable({m=p},{__index=o})
        if o.line:sub(o.col,o.col+#p.info.end_pair-1)==p.info.end_pair
            and putils.run_end_pair_filter(opair)
            and putils.pair_balansed_start(opair)
        then
            return {
                '\n',
                {'pos',o.col,o.row},
                '\n',
            }
        end
    end
end
---@param somepairs ua.prof.def.pair
---@param conf ua.prof.def.cr.conf
---@return ua.prof.def.cr
function M.init(somepairs,conf)
    --TODO: each pair may have it's own backspace config defined
    ---@type ua.prof.def.cr
    return putils.create_obj(conf,{
        run=M.run,
        info={pairs=somepairs},
        doc='autopairs newline',
    })
end
return M
