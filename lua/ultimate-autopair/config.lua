local core=require'ultimate-autopair.core'
local paird=require'ultimate-autopair.configs.default'
local M={}
M.conf={}
function M.add_conf(config)
    table.insert(M.conf,config)
end
function M.init_default(conf,mem)
    paird.init_conf(conf,mem)
end
function M.init_core(conf,mem)
    --TODO: put in configs dir
    for _,v in ipairs(conf) do
        table.insert(mem,v)
    end
end
function M.init_cond(conf,mem)
    --TODO: put in configs dir
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
function M.init_conf(conf,mem)
    if conf.config_init=='default' then
        M.init_default(conf,mem)
    elseif conf.config_init=='core' then
        M.init_core(conf,mem)
    elseif conf.config_init=='cond' then
        M.init_cond(conf,mem)
    elseif type(conf.config_init)=='function' then
        conf.config_init(conf,mem)
    end
end
function M.init()
    core.clear()
    for _,v in ipairs(M.conf) do
        M.init_conf(v,core.mem)
    end
    core.init()
end
return M
