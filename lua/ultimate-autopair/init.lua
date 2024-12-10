local config_lib=require'ultimate-autopair.config'
local defaults=require'ultimate-autopair.default_configs'
local profile=require'ultimate-autopair.profile'
local hook=require'ultimate-autopair.hook'
local utils=require'ultimate-autopair.utils'

local function generate_config(conf)
    return config_lib(conf,defaults.main_config,(conf or {}).validate or 1)
end

local M={}

---@type ua.config?
local config=nil
---@return ua.config
function M.get_config() return config or {} end
---@return ua.config
function M.get_default_config()
    return defaults.main_config
end

---@param conf ua.config?
function M.setup(conf)
    if vim.fn.has('nvim-0.9.2')~=1 then error('Requires at least version nvim-0.9.2') end
    config=conf or {}
    local iconf=generate_config(conf)
    local hooks=profile.init(iconf)
    utils.init(iconf)
    hook.register(hooks)
end
function M.teardown()
    hook.register{}
end

---@param enable boolean
function M.enable(enable) error('TODO') end
---@return boolean
function M.is_enabled() error('TODO') end

---@param key string
---@param fallback string?
---@param mode 'n'|'i'|'c'|'x'|'s'|'o'|'t'|'v'|nil
function M.exec_key(key,fallback,mode)
    local action=M.eval_key(key,fallback,mode) --[[@as string]]
    local utils=require'ultimate-autopair.utils'
    vim.api.nvim_feedkeys(utils.keycode(action),'n',true)
    error('TODO: do action')
end
---@param key string
---@param fallback string|false?
---@param mode 'n'|'i'|'c'|'x'|'s'|'o'|'t'|'v'|nil
---@return string|false
function M.eval_key(key,fallback,mode)
    if mode=='v' then
        mode='x'
    elseif mode==nil then
        mode=error('TODO: vim.fn.mode() may return R and ctrl-v, so we need to implement our own mode() which only returns one of nicxsot') or 'i'
    elseif not mode:match('[nicxsot]') then
        error('Mode should be one of [nicxsotv]: '..mode)
    end
    local action,fl=require'ultimate-autopair.hook'.run_hook('map',mode,key)
    if action==nil then
        if fallback==false then return false end
        return fallback or vim.fn.keytrans(fl or '')
    end
    return vim.fn.keytrans(action)
end

return M
