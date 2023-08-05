local config=require'ultimate-autopair.config'
local M={}
function M.init_conf(conf,mem)
    local lmem={}
    for _,v in ipairs(conf) do
        config.init_conf(v,lmem)
    end
    for _,v in ipairs(lmem) do
        if v.check and conf.check then
            local check=v.check
            v.check=function (...)
                if conf.check(...) then
                    return check(...)
                end
            end
        end
        if v.rule and conf.rule then
            local rule=v.rule
            v.rule=function (...)
                if conf.rule(...) then
                    return rule(...)
                end
            end
        end
        table.insert(mem,v)
    end
end
return M
