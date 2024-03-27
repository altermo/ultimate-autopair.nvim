local hookutils=require'ultimate-autopair.hook.utils'
local putils=require'ultimate-autopair.profile.pair.utils'
---@class ua.prof.def.space.info
---@field pairs ua.prof.def.pair[]
---@class ua.prof.def.space:ua.object
---@field info ua.prof.def.space.info
---@class ua.prof.def.space.conf:ua.prof.def.map

local M={}
---@param o ua.info
---@return ua.actions|nil
function M.run(o)
    local m=o.m --[[@as ua.prof.def.space]]
    local info=m.info
    local first_col=o.line:sub(1,o.col-1):find(' *$')
    local total=o.col-first_col
    local spairs=putils.backwards_get_start_pairs(setmetatable({col=first_col},{__index=o}),info.pairs)
    for _,spair in ipairs(spairs) do
        local opair=setmetatable({m=spair},{__index=o})
        local col,row=putils.next_open_end_pair(opair)
        if not row or not col then goto continue end
        local ototal=#o.line:sub(o.col,col-1):reverse():match('^ *')
        if ototal>total then goto continue end
        if putils.pair_balansed_end(opair) then
            return {
                ' ',
                {'pos',col+1,row},
                (' '):rep(total-ototal+1),
                {'pos',o.col+1,o.row},
            }
        end
        ::continue::
    end
end
---@param somepairs ua.prof.def.pair
---@param conf ua.prof.def.space.conf
---@return ua.prof.def.space
function M.init(somepairs,conf)
    --TODO: each pair may have it's own space config defined
    --TODO: how to do the autocmd stuff... (should only need to change the hook, no other config neceserry (will carry over to make autopair after alpha insert possible))
    ---@type ua.prof.def.space
    return putils.create_obj(conf,{
        run=M.run,
        info={pairs=somepairs},
        doc='autopairs space',
    })
end
return M
