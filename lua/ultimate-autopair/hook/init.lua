local utils=require'ultimate-autopair.utils'
local hookmem=require'ultimate-autopair.hook.mem'
local maphook=require'ultimate-autopair.hook.map'
local userhook=require'ultimate-autopair.hook.user'
local hookutils=require'ultimate-autopair.hook.utils'
local M={}
---@param objects ua.instance
function M.unregister(objects)
    objects.hooked='half'
    objects._cache=nil
    for _,obj in ipairs(objects) do
        for _,v in pairs(obj.hooks) do
            M.unregister_hook(obj,v)
        end
    end
    M.update()
    objects.hooked=false
end
---@param obj ua.object
---@param hash ua.hook.hash
function M.unregister_hook(obj,hash)
    if not hookmem[hash] then return end
    local mem=hookmem[hash]
    for k,v in ipairs(mem) do
        if v==obj then
            table.remove(mem,k)
            mem.dirty=true
            return
        end
    end
    if _G.UA_DEV then error'' end
end
---@param objects ua.instance
function M.register(objects)
    objects.hooked='half'
    objects._cache={}
    for _,obj in ipairs(objects) do
        for _,v in ipairs(obj.hooks) do
            M.register_hook(obj,v)
        end
    end
    M.update()
    objects.hooked=true
end
---@param obj ua.object
---@param hash ua.hook.hash
function M.register_hook(obj,hash)
    if not hookmem[hash] then hookmem[hash]={} end
    local mem=hookmem[hash]
    if UA_DEV then
        assert(not utils.in_list(mem,obj))
    end
    if utils.in_list(mem,obj) then return end
    mem.dirty=true
    table.insert(mem,obj)
end
function M.update()
    for hash,v in pairs(hookmem) do
        if not v.dirty then goto continue end
        v.dirty=false
        local info=hookutils.get_hash_info(hash)
        if #v==0 then
            if info.type=='map' then
                maphook.del(hash)
            elseif info.type=='user' then
                userhook.del(hash)
            else
                error(('hook type `%s` can not be unregistered'):format(info.type))
            end
            hookmem[hash]=nil
            goto continue
        end
        hookutils.stable_sort(v)
        if info.type=='map' then
            maphook.set(hash)
        elseif info.type=='user' then
            userhook.set(hash)
        else
            error(('hook type `%s` can not be registered'):format(info.type))
        end
        ::continue::
    end
end
return M
