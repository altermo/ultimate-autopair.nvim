---@class prof.def.module:core.module
---@field check core.check-fn
---@field filter core.filter-fn
---@field conf table
---@class prof.def.m.pair:prof.def.module
---@field pair string
---@field end_pair string
---@field start_pair string
---@field fn prof.def.pair.fn
---@field key string
---@field conf prof.def.conf.pair
---@field mconf prof.def.conf
---@field multiline boolean
---@field start_m? prof.def.m.pair
---@field end_m? prof.def.m.pair
---@class prof.def.m.map:prof.def.module
---@field map string|string[]
---@field cmap string|string[]
---@field iconf table
---@class prof.def.ext
---@field conf table
---@field name string
---@field m table
---@class prof.def.conf.map
---@field enable boolean?
---@field conf table?
---@field map false?|string|string[]
---@field cmap false?|string|string[]
---@field p number?
---@field multi boolean?
---@class prof.def.conf:prof.mconf
---@field map? boolean
---@field cmap? boolean
---@field pair_map? boolean
---@field pair_cmap? boolean
---@field extensions? table
---@field internal_pairs? table
---@field config_internal_pairs? table
---@field bs? prof.def.map.bs.conf
---@field cr? prof.def.map.cr.conf
---@field space? prof.def.map.space.conf
---@field space2? prof.def.map.space2.conf
---@field fastwarp? prof.def.map.fastwarp.conf
---@field close? prof.def.map.close.conf
---@field tabout? prof.def.map.tabout.conf
---@field [number]? prof.def.conf.pair
---@field multiline? boolean
---@class prof.def.conf.pair
---@field [1] string
---@field [2] string
---@field p? number
---@field cmap? boolean
---@field imap? boolean
---@field multiline? boolean
---@field disable_start? boolean
---@field disable_end? boolean
---@field [string] any
---@class prof.def.q
---@field start_pair string
---@field end_pair string
---@field p number
---@field conf prof.def.conf.pair
---@field extensions prof.def.ext[]
---@field cmap boolean
---@field map boolean
---@field mconf prof.def.conf
---@field multiline boolean
---@class prof.def.m_type
---@class prof.def.pair.fn
---@field can_check fun(o:core.o):boolean?
---@field can_check_pre fun(o:core.o):boolean?
---@field find_corresponding_pair fun(o:core.o,col:number):number|boolean?,number?

local default=require'ultimate-autopair.profile.default.utils'
local pair_s=require'ultimate-autopair.profile.default.pairs'
local pair_as=require'ultimate-autopair.profile.default.pairas'
local pair_ae=require'ultimate-autopair.profile.default.pairae'
local pair_e=require'ultimate-autopair.profile.default.paire'
local M={}
M.maps={
    'bs',
    'close',
    'cr',
    'fastwarp',
    {'rfastwarp','fastwarp'},
    'space',
    'space2',
    'tabout',
}
---@param conf prof.def.conf
---@param mem core.module[]
function M.init(conf,mem)
    local ext=M.prepare_extensions(conf.extensions)
    M.init_ext(mem,conf,ext)
    M.init_pairs(mem,conf,ext,conf)
    M.init_pairs(mem,conf,ext,M.prepare_pairs(conf.internal_pairs,conf.config_internal_pairs))
    M.init_maps(mem,conf,ext)
end
---@param mem core.module[]
---@param conf prof.def.conf
---@param ext prof.def.ext[]
---@param somepairs prof.def.conf.pair[]
function M.init_pairs(mem,conf,ext,somepairs)
    for _,pair in ipairs(somepairs or {}) do
        for _,module in ipairs(M.init_pair(conf,ext,pair)) do
            table.insert(mem,module)
        end
    end
end
---@param conf prof.def.conf
---@param ext prof.def.ext[]
---@param pair prof.def.conf.pair
---@return prof.def.m.pair[]
function M.init_pair(conf,ext,pair)
    local q=M.create_q_value(conf,ext,pair)
    local ps,pe
    if q.start_pair==q.end_pair then
        ps,pe=pair_as.init(q),pair_ae.init(q)
    else
        ps,pe=pair_s.init(q),pair_e.init(q)
    end
    ps.end_m=pe
    pe.end_m=pe
    ps.start_m=ps
    pe.start_m=ps
    return {ps,pe}
end
---@param conf prof.def.conf
---@param ext prof.def.ext[]
---@param pair prof.def.conf.pair
---@return prof.def.q
function M.create_q_value(conf,ext,pair)
    return {
        start_pair=pair[1],
        end_pair=pair[2],
        p=pair.p or conf.p or 10,
        conf=pair,
        extensions=ext,
        cmap=conf.cmap~=false and (pair.cmap or(pair.cmap~=false and conf.pair_cmap~=false)),
        map=conf.map~=false and (pair.imap or (pair.imap~=false and conf.pair_map~=false)),
        multiline=conf.multiline~=false and pair.multiline~=false and (pair.multiline or conf.multiline),
    }
end
---@param somepairs table
---@param configs table
---@return table
function M.prepare_pairs(somepairs,configs)
    if not configs then return somepairs end
    local newpairs=vim.deepcopy(somepairs)
    for _,config in ipairs(configs) do
        for _,pair in ipairs(newpairs) do
            if pair[1]==config[1]
                and pair[2]==config[2] then
                for k,v in pairs(config) do pair[k]=v end
                goto breakit
            end
        end
        error(('internal pair config %s,%s did not match any internal pairs'):format(config[1],config[2]))
        ::breakit::
    end
    return newpairs
end
---@param mem core.module[]
---@param conf prof.def.conf
---@param ext prof.def.ext[]
function M.init_ext(mem,conf,ext)
    for _,v in ipairs(ext) do
        for _,module in ipairs(v.m.init_module and v.m.init_module(v,conf) or {}) do
            table.insert(mem,module)
        end
    end
end
---@param mem core.module[]
---@param conf prof.def.conf
---@param ext prof.def.ext[]
function M.init_maps(mem,conf,ext)
    for _,map in ipairs(M.maps) do
        if type(map)=='string' then
            M.init_map(map,mem,conf[map],conf,ext)
        else
            M.init_map(map[1],mem,conf[map[2]],conf,ext)
        end
    end
end
---@param map_name string
---@param mem core.module[]
---@param confs table
---@param mconf prof.def.conf
---@param ext prof.def.ext[]
function M.init_map(map_name,mem,confs,mconf,ext)
    if confs and not confs.multi then confs={confs} end
    for _,conf in ipairs(confs or {}) do
        local map=require('ultimate-autopair.profile.default.maps.'..map_name)
        conf=vim.tbl_extend('keep',conf,confs)
        if map.init then
            for _,module in pairs({map.init(conf,mconf,ext)}) do
                table.insert(mem,module)
            end
        end
    end
end
---@param extension_confs table
---@return prof.def.ext[]
function M.prepare_extensions(extension_confs)
    local tbl_of_ext_opt={}
    for name,conf in pairs(extension_confs or {}) do
        if conf then
            table.insert(tbl_of_ext_opt,{name=name,conf=conf})
        end
    end
    table.sort(tbl_of_ext_opt,function (a,b) return a.conf.p<b.conf.p end)
    local ret={}
    for _,opt in ipairs(tbl_of_ext_opt) do
        table.insert(ret,{m=default.load_extension(opt.name),name=opt.name,conf=opt.conf})
    end
    return ret
end
return M
