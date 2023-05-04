--TODO: implement extensions for newline
local default=require 'ultimate-autopair.configs.default.utils'
local M={}
function M.newline(o,m)
    --TODO: run filtering extensions
    for _,v in ipairs(default.filter_pair_type({'donewline','pair'})) do
        if v.newline then
            --TODO: check v.rule()
            local ret=v.newline(o,m,m.conf)
            if ret then return ret end
        end
    end
end
function M.wrapp_newline(m)
    return function (o)
        if default.key_check_cmd(o,m.map,m.map,m.cmap,m.cmap) then
            return M.newline(o,m)
        end
    end
end
function M.init(conf,mconf)
    if not conf.enable then return end
    local m={}
    m.conf=conf
    m.map=mconf.map and conf.map
    m.cmap=mconf.cmap and conf.cmap
    m.p=conf.p or 10
    m.check=M.wrapp_newline(m)
    m.get_map=default.get_mode_map_wrapper(m.map,m.cmap)
    return m
end
return M
