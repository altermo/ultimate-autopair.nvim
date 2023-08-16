---@class prof.def.map.cr.conf:prof.def.conf.map
---@field autoclose boolean?
---@field cmap nil
---@class prof.def.map.cr.m.newline:prof.def.module
---@field newline prof.def.map.cr.fn
---@alias prof.def.map.cr.fn fun(o:core.o,m:prof.def.m.map,conf:prof.def.map.cr.conf):string?

local default=require 'ultimate-autopair.profile.default.utils'
local M={}
---@param o core.o
---@param m prof.def.m.map
---@return string?
function M.newline(o,m)
    for _,v in ipairs(default.filter_for_opt('donewline')) do
        ---@cast v prof.def.map.cr.m.newline
        local ret=v.newline(o,m,m.iconf)
        if ret then return ret end
    end
end
---@param m prof.def.m.map
---@return core.check-fn
function M.wrapp_newline(m)
    return function (o)
        return M.newline(o,m)
    end
end
---@param conf prof.def.map.cr.conf
---@param mconf prof.def.conf
---@param ext prof.def.ext[]
---@return prof.def.m.map?
function M.init(conf,mconf,ext)
    if conf.enable==false then return end
    local m={}
    m.iconf=conf
    m.conf=conf.conf or {}
    m.map=mconf.map~=false and conf.map
    m.extensions=ext
    m[default.type_def]={'newline'}
    m.p=conf.p or mconf.p or 10
    m.doc='autopairs newline key map'

    m.check=M.wrapp_newline(m)
    m.filter=default.def_filter_wrapper(m)
    default.init_extensions(m,m.extensions)
    m.get_map=default.def_map_get_map_wrapper(m)
    default.extend_map_check_with_map_check(m)
    return m
end
return M
