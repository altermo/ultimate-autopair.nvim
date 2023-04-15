local M={}
local pair_s=require'ultimate-autopair.pair.default.pairs'
local pair_a=require'ultimate-autopair.pair.default.paira'
local pair_e=require'ultimate-autopair.pair.default.paire'
local default=require'ultimate-autopair.pair.default.utils.default'
local bs=require'ultimate-autopair.pair.default.maps.bs'
local cr=require'ultimate-autopair.pair.default.maps.cr'
local space=require'ultimate-autopair.pair.default.maps.space'
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
    bs.init(conf,mem,mconf)
end
function M.init_cr(conf,mem,mconf)
    cr.init(conf,mem,mconf)
end
function M.init_space(conf,mem,mconf)
    space.init(conf,mem,mconf)
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
            cmap=default.select_opt(v.cmap,mconf.cmap),
            nomap=default.select_opt(v.nomap,mconf.nomap),
        })) do
            table.insert(mem,i)
        end
    end
end
return M
