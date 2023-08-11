---@class prof.def.map.bs.conf:prof.def.conf.map
---@field overjumps boolean?
---@field space boolean?
---@field indent boolean?
---@class prof.def.map.bs.m.backspace:prof.def.module
---@field backspace prof.def.map.bs.fn
---@alias prof.def.map.bs.fn fun(o:core.o,m:prof.def.m.map,conf:prof.def.map.bs.conf):string?

local default=require 'ultimate-autopair.profile.default.utils'
local M={}
---@param o core.o
---@param m prof.def.m.map
---@return string?
function M.backspace(o,m)
    for _,v in ipairs(default.filter_for_opt('dobackspace')) do
        ---@cast v prof.def.map.bs.m.backspace
        local ret=v.backspace(o,m,m.iconf)
        if ret then return ret end
    end
end
---@param m prof.def.m.map
---@return core.check-fn
function M.wrapp_backspace(m)
    return function (o)
        return M.backspace(o,m)
    end
end
---@param conf prof.def.map.bs.conf
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
    m.cmap=mconf.cmap~=false and conf.cmap
    m[default.type_def]={'backspace'}
    m.p=conf.p or mconf.p or 10
    m.doc='autopairs backspace key map'

    m.check=M.wrapp_backspace(m)
    m.filter=default.def_filter_wrapper(m)
    default.init_extensions(m,m.extensions)
    m.get_map=default.def_map_get_map_wrapper(m)
    default.extend_map_check_with_map_check(m)
    return m
end
return M
