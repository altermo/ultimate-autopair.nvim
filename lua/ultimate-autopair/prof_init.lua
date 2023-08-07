---@class prof.config
---@field profile? string
---@class prof.mconf:prof.config
---@field p? number

local core=require'ultimate-autopair.core'
local M={}
---@param profile string|function
---@return function
function M.get_profile_init(profile)
    if type(profile)=='function' then
        return profile
    end
    return require('ultimate-autopair.profile.'..profile).init
end
---@param conf prof.config
---@param mem core.module[]
function M.init_conf(conf,mem)
    if type(conf)=='function' then
        conf({profile='_function'},mem) return
    end
    if not conf.profile then conf.profile='default' end
    M.get_profile_init(conf.profile)(conf,mem)
end
---@param confs prof.config[]
---@param mem core.module[]
function M.init(confs,mem)
    mem=mem or core.mem
    for _,conf in ipairs(confs) do
        M.init_conf(conf,mem)
    end
end
return M
