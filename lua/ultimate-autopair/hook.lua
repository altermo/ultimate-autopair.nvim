local utils=require'ultimate-autopair.utils'
---@alias ua.hook.callback fun(con:ua.context.pos):ua.actions?

---@alias ua.hook.mode 'i'|'c'|'t'|'x'|'o'|'s'|'n'
---@alias ua.hook.key string

---@class ua.hook
---@field mode ua.hook.mode
---@field key ua.hook.key
---@field callback ua.hook.callback
---@field doc string
---@field fallback string?
---@field priority number

---@class ua.hooks
---@field [number] ua.hook
---@field fallback string?
---@field hooked boolean

---@type table<ua.hook.mode,table<ua.hook.key,ua.hooks>>
local hookmem=vim.defaulttable(function () return {} end)
---@return fun():ua.hook.mode,ua.hook.key,ua.hooks
local function iter_hookmem()
    return coroutine.wrap(function ()
        for mode,key_to_hooks in pairs(hookmem) do
            for key,hooks in pairs(key_to_hooks) do
                coroutine.yield(mode,key,hooks)
            end
        end
    end)
end
---@param hooks ua.hooks
---@return string?
local function get_fallback(hooks)
    local fallback=nil
    for _,hook in ipairs(hooks) do
        local f=hook.fallback
        fallback=f or fallback
    end
    return fallback
end
---@param action ua.actions
---@return string?
local function action_to_keys(action)
    local out={}
    local mode=vim.fn.mode()
    local key_left,key_right
    if mode=='i' or mode=='R' then
        key_left=utils.key_noundo..utils.key_left
        key_right=utils.key_noundo..utils.key_right
    else
        key_left=utils.key_left
        key_right=utils.key_right
    end
    for _,act in ipairs(action) do
        if type(act)=='string' then
            table.insert(out,act)
        elseif act[1]=='h' then
            table.insert(out,utils.keycode(key_left:rep(utils.len(act[2]))))
        elseif act[1]=='l' then
            table.insert(out,utils.keycode(key_right:rep(utils.len(act[2]))))
        else
            error('TODO')
        end
    end
    return table.concat(out,'')
end
---@param keys string
local function keys_add_abbrev_expand(keys)
    if keys:sub(1,1)=='\r' then
        return '\x1d'..keys
    elseif vim.regex('^[^[:keyword:][:cntrl:]\x80]'):match_str(keys) then
        return '\x1d'..keys
    end
    return keys
end
---@param hooks ua.hooks
---@return string?
local function run_callbacks(hooks)
    local o=utils.create_context()
    for _,hook in ipairs(hooks) do
        local ret=hook.callback(o)
        if ret then
            return action_to_keys(ret)
        end
    end
end
---@param mode ua.hook.mode
---@param key ua.hook.key
local function vim_map(mode,key)
    if not (mode:match('[nicxsot]')) then
        error('Mode should be one of [nicxsot]: '..mode)
    end
    if key:find'\0' then
        error('Null byte found in pair, mapping this crashes neovim')
    end
    local hooks=assert(hookmem[mode][key])
    local desc={}
    local fallback=get_fallback(hooks) or ''
    vim.keymap.set(mode,key,function ()
        local keys=run_callbacks(hooks) or fallback
        if mode=='i' or mode=='c' then
            keys=keys_add_abbrev_expand(keys)
        end
        return keys
    end,{noremap=true,expr=true,replace_keycodes=false,desc=table.concat(desc,'\n\t\t ')})
    hooks.hooked=true
end
---@param mode ua.hook.mode
---@param key ua.hook.key
local function vim_unmap(mode,key)
    local hooks=assert(hookmem[mode][key])
    vim.keymap.del(mode,key)
    hooks.hooked=false
end
local function autohook_all()
    for mode,key,hooks in iter_hookmem() do
        if #hooks==0 and hooks.hooked then
            vim_unmap(mode,key)
        elseif #hooks>0 then
            vim_map(mode,key)
        end
    end
end
---@param hook ua.hook
local function register_hook(hook)
    if not hookmem[hook.mode][hook.key] then
        hookmem[hook.mode][hook.key]={hooked=false}
    end
    table.insert(hookmem[hook.mode][hook.key],hook)
end
local function unregister_all()
    for mode,key,_ in iter_hookmem() do
        hookmem[mode][key]={hooked=hookmem[mode][key].hooked}
    end
end
---@param tbl ua.hooks
local function stable_sort(tbl)
    local col=vim.defaulttable(function () return {} end)
    for _,v in ipairs(tbl) do
        table.insert(col[-v.priority],v)
    end
    if not next(col,next(col)) then return end
    local i=1
    for _,t in vim.spairs(col) do
        table.move(t,1,#t,i,tbl)
        i=i+#t
    end
end
local function sort_hooks()
    for _,_,hooks in iter_hookmem() do
        stable_sort(hooks)
    end
end
local M={}
---@param mode ua.hook.mode
---@param key ua.hook.key
---@return string?
---@return string?
function M.run_hook(mode,key)
    local hooks=hookmem[mode][key]
    if not hooks then
        error(('No hook registered for mode: %s, key: %s'):format(mode,key))
    end
    return run_callbacks(hooks),get_fallback(hooks)
end
---@param hooks ua.hook[]
function M.register(hooks)
    unregister_all()
    for _,hook in ipairs(hooks) do
        register_hook(hook)
    end
    sort_hooks()
    autohook_all()
end
---@param callback ua.hook.callback
---@param mode ua.hook.mode
---@param key string
---@param doc string
---@param fallback string|false?
---@param priority number
---@return ua.hook
function M.create_hook(callback,mode,key,doc,fallback,priority)
    ---@type ua.hook
    return {
        callback=callback,
        mode=mode,
        key=key,
        doc=doc,
        fallback=utils.keycode(fallback or nil),
        priority=priority
    }
end
return M
