--TODO: add map configs to all pairs...
local M={}
local pair_s=require'ultimate-autopair.configs.default.pairs'
local pair_a=require'ultimate-autopair.configs.default.paira'
local pair_e=require'ultimate-autopair.configs.default.paire'
local default=require'ultimate-autopair.configs.default.utils'
local bs=require'ultimate-autopair.configs.default.maps.bs'
local cr=require'ultimate-autopair.configs.default.maps.cr'
local space=require'ultimate-autopair.configs.default.maps.space'
function M.init_multi(q)
    if q.start_pair==q.end_pair then
        return {pair_a.init(q)}
    else
        return {pair_s.init(q),pair_e.init(q)}
    end
end
function M.init_conf(conf,mem)
    M.init_pair(conf,mem,conf)
    M.init_pair(conf.internal_pairs,mem,conf)
    M.init_bs(conf.bs,mem,conf)
    M.init_cr(conf.cr,mem,conf)
    M.init_space(conf.space,mem,conf)
end
function M.clear()
end
function M.init_bs(conf,mem,mconf)
    table.insert(mem,bs.init(conf,mconf))
end
function M.init_cr(conf,mem,mconf)
    table.insert(mem,cr.init(conf,mconf))
end
function M.init_space(conf,mem,mconf)
    table.insert(mem,space.init(conf,mconf))
end
function M.init_pair(conf,mem,mconf)
    local ext=default.prepare_extensions(mconf.extensions)
    for _,v in ipairs(conf) do
        for _,i in ipairs(M.init_multi({
            start_pair=v[1],
            end_pair=v[2],
            p=v.p or mconf.p,
            conf=v,
            extensions=ext,
            cmap=mconf.cmap and default.select_opt(v.cmap,mconf.pair_cmap,true),
            map=mconf.map and default.select_opt(v.imap,mconf.pair_map,true),
        })) do
            table.insert(mem,i)
        end
    end
end
return M
