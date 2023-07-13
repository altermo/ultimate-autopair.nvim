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
function M.init_raw(conf,mem)
    require'ultimate-autopair.configs.other.raw'.init_conf(conf,mem)
end
function M.init_cond(conf,mem)
    require'ultimate-autopair.configs.other.cond'.init_conf(conf,mem)
end
function M.init_map(conf,mem)
    require'ultimate-autopair.configs.other.map'.init_conf(conf,mem)
end
function M.init_multi(conf,mem)
    require'ultimate-autopair.configs.other.multi'.init_conf(conf,mem)
end
function M.init_conf(conf,mem)
    if conf.config_type=='default' then
        M.init_default(conf,mem)
    elseif conf.config_type=='raw' then
        M.init_raw(conf,mem)
    elseif conf.config_type=='cond' then
        M.init_cond(conf,mem)
    elseif conf.config_type=='map' then
        M.init_map(conf,mem)
    elseif conf.config_type=='multi' then
        M.init_multi(conf,mem)
    elseif type(conf.config_type)=='function' then
        conf.config_type(conf,mem)
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
