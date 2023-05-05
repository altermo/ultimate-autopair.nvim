local M={}
function M.init_conf(conf,mem)
    local lmem={}
    for _,v in ipairs(conf) do
        M.init_conf(v,lmem)
    end
    for _,v in ipairs(lmem) do
        local check=v.check
        v.check=function (...)
            if conf.check(...) then
                return check(...)
            end
        end
        table.insert(mem,v)
    end
end
return M
