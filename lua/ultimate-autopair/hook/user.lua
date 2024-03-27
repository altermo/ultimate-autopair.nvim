local hookutils=require'ultimate-autopair.hook.utils'
local M={}
M.hooks={}
---@param hash ua.hook.hash
function M.del(hash)
    local info=hookutils.get_hash_info(hash)
    assert(info.type=='user')
    if _G.UA_DEV then
        assert(M.hooks[info.key])
    end
    M.hooks[info.key]=nil
end
---@param hash ua.hook.hash
---@param _ ua.hook.conf?
function M.set(hash,_)
    local info=hookutils.get_hash_info(hash)
    if _G.UA_DEV then
        assert(not M.hooks[info.key])
    end
    M.hooks[info.key]=function ()
        local act,subconf=hookutils.get_act(hash,hookutils.get_mode())
        vim.api.nvim_feedkeys(hookutils.act_to_keys(act,hookutils.get_mode(),subconf),'n',false)
    end
end
return M
