local default=require 'ultimate-autopair.configs.default.utils'
local M={}
function M.newline(o,m)
    for _,v in ipairs(default.filter_pair_type({'donewline','pair'})) do
        if v.newline then
            local ret=(not v.rule or v.rule()) and v.newline(o,m,m.iconf)
            if ret then return ret end
        end
    end
end
function M.wrapp_newline(m)
    return function (o)
        return M.newline(o,m)
    end
end
function M.init(conf,mconf,ext)
    if conf.enable==false then return end
    local m={}
    m.iconf=conf
    m.conf=conf.conf or {}
    m.map=mconf.map~=false and conf.map
    m.p=conf.p or 10
    m.extensions=ext
    m._type={[default.type_pair]={'newline'}}
    m.check=M.wrapp_newline(m)
    m.get_map=default.get_mode_map_wrapper(m.map)
    m.rule=function () return true end
    default.init_extensions(m,m.extensions)
    local check=m.check
    m.check=function (o)
        o.wline=o.line
        o.wcol=o.coll
        if not default.key_check_cmd(o,m.map,m.map) then return end
        if not m.rule() then return end
        return check(o)
    end
    m.doc='autopairs newline key map'
    return m
end
return M
