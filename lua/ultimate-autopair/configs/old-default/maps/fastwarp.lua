local default=require'ultimate-autopair.configs.default.utils.default'
local mutils=require'ultimate-autopair.configs.default.maps.utils'
local M={}
M.fn={}
function M.fn.fast(o,m,conf)
    for _,v in ipairs(default.filter_pair_type({'fastwarp','pair'})) do
        if v.fastwarp then
            --TODO: check pair spesific rules
            local ret=v.fastwarp(o,m,conf)
            if ret then
                return ret
            end
        end
    end
end
function M.fastwarp(o,m,conf)
    --TODO: implement a way to run only filtering and ruling extensions
    for _,v in pairs(M.fn) do
        local ret=v(o,m,conf)
        if ret then
            return ret
        end
    end
end
function M.fastwarp_wrapper(m,conf)
    return function (o)
        if default.key_eq_mode(o,conf.map,conf.cmap) then
            return M.fastwarp(o,m,conf)
        end
    end
end
function M.init(conf,mem,_)
    if not conf.enable then return end
    local m={}
    m.check=M.fastwarp_wrapper(m,conf)
    m.p=10
    m.get_map=mutils.get_map_wrapper(conf)
    table.insert(mem,m)
end
return M
