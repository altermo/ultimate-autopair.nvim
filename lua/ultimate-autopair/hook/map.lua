local hookmem=require'ultimate-autopair.hook.mem'
local hookutils=require'ultimate-autopair.hook.utils'
local M={}
---@param hash ua.hook.hash
function M.del(hash)
    local info=hookutils.get_hash_info(hash)
    assert(info.type=='map')
    local conf=info.conf
    assert(type(conf.mode)=='string')
    if _G.UA_DEV then
        assert(vim.fn.mapcheck(info.key,conf.mode)~='')
    end
    vim.keymap.del(conf.mode,info.key)
end
---@param hash ua.hook.hash
---@param conf ua.hook.conf?
function M.set(hash,conf)
    if conf=='expr' or not conf then
        M.expr_set(hash)
    else
        error()
    end
end
---@param hash ua.hook.hash
function M.expr_set(hash)
    local info=hookutils.get_hash_info(hash)
    assert(info.type=='map')
    local conf=info.conf
    assert(type(conf.mode)=='string')
    if _G.UA_DEV then
        assert(vim.fn.mapcheck(info.key,conf.mode)=='')
    end
    local objs=hookmem[hash]
    local desc={}
    for _,obj in ipairs(objs) do
        table.insert(desc,obj.doc)
    end
    if info.key:find'\0' then
        error('Null byte found in pair, exiting before a crash can happen')
    end
    vim.keymap.set(conf.mode,info.key,function ()
        local act,subconf=hookutils.get_act(hash,conf.mode)
        return hookutils.act_to_keys(act,conf.mode,subconf)
    end,{noremap=true,expr=true,replace_keycodes=false,desc=table.concat(desc,'\n\t\t ')})
end
return M
