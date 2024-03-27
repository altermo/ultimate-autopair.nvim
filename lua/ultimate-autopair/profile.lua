local M={}
---@param profile string|function
---@return fun(conf:ua.prof.conf,objects:ua.instance)
function M.get_profile_init(profile)
    if type(profile)=='function' then return profile end
    return require('ultimate-autopair.profile.'..profile).init
end
---@param conf ua.prof.conf
---@param objects ua.instance
function M.init_conf(conf,objects)
    M.get_profile_init(conf.profile or 'default')(conf,objects)
end
---@param confs ua.prof.conf[]
---@param objects? ua.instance
---@return ua.instance
function M.init(confs,objects)
    objects=objects or {}
    for _,conf in ipairs(confs) do
        M.init_conf(conf,objects)
    end
    return objects
end
return M
