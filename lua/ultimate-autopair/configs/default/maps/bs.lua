--TODO: implement extensions for backspace
local default=require 'ultimate-autopair.configs.default.utils'
local M={}
function M.backspace(o,m)
    --TODO: run filtering extensions
    for _,v in ipairs(default.filter_pair_type({'dobackspace','pair'})) do
        if v.backspace then
            --TODO: check v.rule()
            local ret=v.backspace(o,m,m.conf)
            if ret then
                return ret
            end
        end
    end
end
function M.wrapp_backspace(m)
    return function (o)
        if default.key_check_cmd(o,m.map,m.map,m.cmap,m.cmap) then
            return M.backspace(o,m)
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
    m.check=M.wrapp_backspace(m)
    m.get_map=default.get_mode_map_wrapper(m.map,m.cmap)
    return m
end
return M
