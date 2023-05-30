local M={}
local pair_s=require'ultimate-autopair.configs.default.pairs'
local pair_a=require'ultimate-autopair.configs.default.paira'
local pair_t=require'ultimate-autopair.configs.default.pairt'
local pair_e=require'ultimate-autopair.configs.default.paire'
local default=require'ultimate-autopair.configs.default.utils'
local bs=require'ultimate-autopair.configs.default.maps.bs'
local cr=require'ultimate-autopair.configs.default.maps.cr'
local space=require'ultimate-autopair.configs.default.maps.space'
local space2=require'ultimate-autopair.configs.default.maps.space2'
local fastwarp=require'ultimate-autopair.configs.default.maps.fastwarp'
local rfastwarp=require'ultimate-autopair.configs.default.maps.rfastwarp'
function M.init_multi(q)
    if q.type=='tsnode' then
        return {pair_t.init(q)}
    elseif q.start_pair==q.end_pair then
        return {pair_a.init(q)}
    else
        return {pair_s.init(q),pair_e.init(q)}
    end
end
function M.init_conf(conf,mem)
    local ext=default.prepare_extensions(conf.extensions)
    M.init_ext(ext,mem,conf)
    M.init_pair(conf,mem,conf,ext)
    M.init_pair(conf.internal_pairs,mem,conf,ext)
    M.init_bs(conf.bs,mem,conf,ext)
    M.init_cr(conf.cr,mem,conf,ext)
    M.init_space(conf.space,mem,conf,ext)
    M.init_space2(conf.space2,mem,conf,ext)
    M.init_fastwarp(conf.fastwarp,mem,conf,ext)
    M.init_rfastwarp(conf.fastwarp,mem,conf,ext)
end
function M.init_ext(ext,mem,mconf)
    for _,v in ipairs(ext) do
        if v.m.init_map then
            local Iextmap=v.m.init_map(v,mconf)
            if Iextmap then table.insert(mem,Iextmap) end
        end
    end
end
function M.clear()
end
function M.init_bs(conf,mem,mconf,ext)
    local Ibs=bs.init(conf or {},mconf,ext)
    if Ibs then table.insert(mem,Ibs) end
end
function M.init_cr(conf,mem,mconf,ext)
    local Icr=cr.init(conf or {},mconf,ext)
    if Icr then table.insert(mem,Icr) end
end
function M.init_space(conf,mem,mconf,ext)
    local Ispace=space.init(conf or {},mconf,ext)
    if Ispace then table.insert(mem,Ispace) end
end
function M.init_space2(conf,mem,mconf,ext)
    local Ispace=space2.init(conf or {},mconf,ext)
    if Ispace then table.insert(mem,Ispace) end
end
function M.init_fastwarp(conf,mem,mconf,ext)
    local Ifastwarp,Idont=fastwarp.init(conf or {},mconf,ext)
    if Ifastwarp then table.insert(mem,Ifastwarp) end
    if Idont then table.insert(mem,Idont) end
end
function M.init_rfastwarp(conf,mem,mconf,ext)
    local Irfastwarp,Idont=rfastwarp.init(conf or {},mconf,ext)
    if Irfastwarp then table.insert(mem,Irfastwarp) end
    if Idont then table.insert(mem,Idont) end
end
function M.init_pair(conf,mem,mconf,ext)
    for _,v in ipairs(conf or {}) do
        for _,i in ipairs(M.init_multi({
            start_pair=v[1],
            end_pair=v[2],
            p=v.p or mconf.p,
            conf=v,
            extensions=ext,
            cmap=mconf.cmap~=false and default.select_opt(v.cmap,mconf.pair_cmap,true),
            map=mconf.map~=false and default.select_opt(v.imap,mconf.pair_map,true),
            type=v.type,
            mconf=mconf,
        })) do
            table.insert(mem,i)
        end
    end
end
return M
