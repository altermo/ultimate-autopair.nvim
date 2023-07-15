local default=require 'ultimate-autopair.configs.default.utils'
local M={}
function M.backspace(o,m)
    for _,v in ipairs(default.filter_pair_type({'dobackspace','pair'})) do
        if v.backspace then
            local ret=(not v.rule or v.rule()) and v.backspace(o,m,m.iconf)
            if ret then return ret end
        end
    end
end
function M.wrapp_backspace(m)
    return function (o)
        return M.backspace(o,m)
    end
end
function M.init(conf,mconf,ext)
    if conf.enable==false then return end
    local m={}
    m.iconf=conf
    m.conf=conf.conf or {}
    m.map=mconf.map~=false and conf.map
    m.cmap=mconf.cmap~=false and conf.cmap
    m.p=conf.p or 10
    m.extensions=ext
    m[default.type_pair]={'backspace'}
    m.check=M.wrapp_backspace(m)
    m.get_map=default.get_mode_map_wrapper(m.map,m.cmap)
    m.rule=function () return true end
    default.init_extensions(m,m.extensions)
    default.init_check_map(m)
    m.doc='autopairs backspace key map'
    return m
end
return M
