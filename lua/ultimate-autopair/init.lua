local M={_id=0}
---@type table<ua.id,ua.instance>
local instances={}
---@return table<ua.id,ua.instance>
M['~get_instances']=function() return instances end
local default=require'ultimate-autopair.default'
local prof=require'ultimate-autopair.profile'
local hook=require'ultimate-autopair.hook'
---@param conf ua.prof.conf?
---@param id ua.id?
function M.setup(conf,id)
    if vim.fn.has('nvim-0.9.0')~=1 then error('Requires at least version nvim-0.9.0') end
    M.init({M.extend_default(conf)},id)
end
---@param configs ua.prof.conf[]
---@param id ua.id?
function M.init(configs,id)
    id=id or M._id
    M.deinit(id)
    instances[id]=prof.init(configs)
    hook.register(instances[id])
end
---@param id ua.id?
function M.deinit(id)
    id=id or M._id
    if instances[id] then hook.unregister(instances[id]) end
end
---@param conf ua.prof.conf?
---@return ua.prof.conf
function M.extend_default(conf)
    if conf and conf.profile and conf.profile~='default' then
        return conf
    end
    return require'ultimate-autopair.profile.pair.confsys'.merge_configs(default.conf,conf)
end
return M
