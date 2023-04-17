local default=require'ultimate-autopair.configs.default.utils.default'
local M={}
M.fn={}
function M.fn.delete_pair(o,m,conf)
    for _,v in ipairs(default.filter_pair_type()) do
        if v.backspace then
            --TODO: check pair spesific rules
            local ret=v.backspace(o,m,conf)
            if ret then
                return ret
            end
        end
    end
end
function M.backspace(o,m,conf)
    --TODO: implement a way to run only filtering and ruling extensions
    for _,v in pairs(M.fn) do
        local ret=v(o,m,conf)
        if ret then
            return ret
        end
    end
end
function M.backspace_wrapper(m,conf)
    return function (o)
        if o.key==(conf.map or '<bs>') then
            return M.backspace(o,m,conf)
        end
    end
end
function M.init(conf,mem,mconf)
    if not conf.enable then return end
    local m={}
    m.check=M.backspace_wrapper(m,conf)
    m.p=10
    function m.get_map(mode)
        if mode=='i' and not conf.nomap then
            return {conf.map or '<bs>'}
        elseif mode=='c' and (conf.nocmap or mconf.cmap) then
            return {conf.cmap or '<bs>'}
        end
    end
    table.insert(mem,m)
end
return M
