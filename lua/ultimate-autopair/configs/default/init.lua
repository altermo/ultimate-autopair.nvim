local M={}
local pair_s=require'ultimate-autopair.configs.default.pairs'
local pair_as=require'ultimate-autopair.configs.default.pairas'
local pair_ae=require'ultimate-autopair.configs.default.pairae'
local pair_t=require'ultimate-autopair.configs.default.pairt'
local pair_e=require'ultimate-autopair.configs.default.paire'
local default=require'ultimate-autopair.configs.default.utils'
local bs=require'ultimate-autopair.configs.default.maps.bs'
local cr=require'ultimate-autopair.configs.default.maps.cr'
local space=require'ultimate-autopair.configs.default.maps.space'
local space2=require'ultimate-autopair.configs.default.maps.space2'
local fastwarp=require'ultimate-autopair.configs.default.maps.fastwarp'
local rfastwarp=require'ultimate-autopair.configs.default.maps.rfastwarp'
local close=require'ultimate-autopair.configs.default.maps.close'
M.I={}
function M.I.wrapp_map(module)
    return function (confs,mem,mconf,ext)
        if confs and not confs.multi then confs={confs} end
        for _,conf in ipairs(confs or {}) do
            conf=vim.tbl_extend('keep',conf,confs)
            local I=module.init(conf or {},mconf,ext)
            if I then table.insert(mem,I) end
        end
    end
end
function M.I.select_opt(...)
    for _,v in pairs({...}) do
        if v~=nil then
            return v
        end
    end
end
function M.init_multi(q)
    if q.type=='tsnode' then
        return {pair_t.init(q)}
    elseif q.start_pair==q.end_pair then
        return {pair_as.init(q),pair_ae.init(q)}
    else
        return {pair_s.init(q),pair_e.init(q)}
    end
end
function M.prepare_pairs(somepairs,configs)
    if not configs then return somepairs end
    local newpairs=vim.deepcopy(somepairs)
    for _,config in ipairs(configs) do
        local flag
        for _,pair in ipairs(newpairs) do
            if pair[1]==config[1]
                and pair[2]==config[2]
                and pair.type==config.type then
                for k,v in pairs(config) do
                    pair[k]=v
                end
                flag=true
            end
        end
        if not flag then error(('internal pair config %s,%s did not match any internal pairs'):format(config[1],config[2] or config.type)) end
    end
    return newpairs
end
function M.init_conf(conf,mem)
    local ext=default.prepare_extensions(conf.extensions)
    M.init_ext(ext,mem,conf)
    M.init_pair(conf,mem,conf,ext)
    M.init_pair(M.prepare_pairs(conf.internal_pairs,conf.config_internal_pairs),mem,conf,ext)
    M.init_bs(conf.bs,mem,conf,ext)
    M.init_cr(conf.cr,mem,conf,ext)
    M.init_space(conf.space,mem,conf,ext)
    M.init_space2(conf.space2,mem,conf,ext)
    M.init_fastwarp(conf.fastwarp,mem,conf,ext)
    M.init_rfastwarp(conf.fastwarp,mem,conf,ext)
    M.init_close(conf.close,mem,conf,ext)
end
function M.init_ext(ext,mem,mconf)
    for _,v in ipairs(ext) do
        if v.m.init_map then
            local Iextmap=v.m.init_map(v,mconf)
            if Iextmap then table.insert(mem,Iextmap) end
        end
    end
end
M.init_bs=M.I.wrapp_map(bs)
M.init_cr=M.I.wrapp_map(cr)
M.init_space=M.I.wrapp_map(space)
M.init_space2=M.I.wrapp_map(space2)
M.init_close=M.I.wrapp_map(close)
function M.init_fastwarp(confs,mem,mconf,ext)
    if confs and not confs.multi then confs={confs} end
    for _,conf in ipairs(confs or {}) do
        conf=vim.tbl_extend('keep',conf,confs)
        local Ifastwarp,Idont=fastwarp.init(conf or {},mconf,ext)
        if Ifastwarp then table.insert(mem,Ifastwarp) end
        if Idont then table.insert(mem,Idont) end
    end
end
function M.init_rfastwarp(confs,mem,mconf,ext)
    if confs and not confs.multi then confs={confs} end
    for _,conf in ipairs(confs or {}) do
        conf=vim.tbl_extend('keep',conf,confs)
        local Irfastwarp,Idont=rfastwarp.init(conf or {},mconf,ext)
        if Irfastwarp then table.insert(mem,Irfastwarp) end
        if Idont then table.insert(mem,Idont) end
    end
end
function M.init_pair(conf,mem,mconf,ext)
    for _,v in ipairs(conf or {}) do
        for _,i in ipairs(M.init_multi({
            start_pair=v[1],
            end_pair=v[2],
            p=v.p or mconf.p,
            conf=v,
            extensions=ext,
            cmap=mconf.cmap~=false and M.I.select_opt(v.cmap,mconf.pair_cmap,true),
            map=mconf.map~=false and M.I.select_opt(v.imap,mconf.pair_map,true),
            type=v.type,
            mconf=mconf,
        })) do
            table.insert(mem,i)
        end
    end
end
return M
