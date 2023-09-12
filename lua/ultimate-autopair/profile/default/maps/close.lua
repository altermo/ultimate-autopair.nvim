---@class prof.def.map.close.conf:prof.def.conf.map
---@field do_nothing_if_fail boolean?

local default=require 'ultimate-autopair.profile.default.utils'
local utils=require 'ultimate-autopair.utils'
local M={}
M.I={}
---@param tbl prof.def.m.pair[]
---@param pair_end prof.def.m.pair
---@return number?
---TODO: DEAD CODE
function M.I.tbl_find(tbl,pair_end)
    for k,v in ipairs(tbl) do
        if v==pair_end.start_m then
            return k
        end
    end
end
---@param o core.o
---@param col number
---@param multiline? boolean
---@return prof.def.m.map[]
function M.get_open_start_pairs(o,col,multiline)
    local pair={}
    local i=1
    while i<col do
        local pair_start=default.get_pairs_by_pos(o,i,'start',true,multiline and function (p) return p.multiline end or nil)[1]
        if pair_start then
            local pcol=pair_start.fn.find_corresponding_pair(o,i)
            if pcol==false then
                table.insert(pair,1,pair_start)
            elseif pcol and pcol>=col then
                pair={}
            end
            i=i+#pair_start.pair
        else
            i=i+1
        end
    end
    return pair
end
---@param o core.o
---@return string?
function M.close(o)
    local pair=M.get_open_start_pairs(o,o.col)
    local epairs=vim.fn.join(vim.tbl_map(function(x) return x.end_pair end,pair),'')
    return utils.create_act({
        epairs,
        {'h',#epairs},
    })
end
---@param _ prof.def.m.map
---@return core.check-fn
function M.wrapp_close(_)
    return function (o)
        return M.close(o)
    end
end
---@param _ prof.def.m.map
---@return prof.def.map.cr.fn
function M.wrapp_newline(_)
    return function(o,_,conf)
        if not conf.autoclose then return end
        local pair=M.get_open_start_pairs(o,o.col,true)
        local epairs=vim.fn.join(vim.tbl_map(function(x) return x.end_pair end,pair),'')
        if epairs=='' then return end
        return utils.create_act({
            {'end'},
            {'newline'},
            epairs,
            {'k',1},
            {'home'},
            {'l',o.col-1},
            {'newline'},
        })
    end
end
---@param conf prof.def.map.close.conf
---@param mconf prof.def.conf
---@param ext prof.def.ext[]
---@return prof.def.m.map?
---@return prof.def.m.map?
function M.init(conf,mconf,ext)
    if conf.enable==false then return end
    local m={}
    m.iconf=conf
    m.conf=conf.conf or {}
    m.map=mconf.map~=false and conf.map
    m.cmap=mconf.cmap~=false and conf.cmap
    m.extensions=ext
    m[default.type_def]={'close','donewline'}
    m.p=conf.p or mconf.p or 10
    m.doc='autopairs close key map'

    m.check=M.wrapp_close(m)
    m.filter=default.def_filter_wrapp(m)
    m.newline=M.wrapp_newline(m)
    default.init_extensions(m,m.extensions)
    m.get_map=default.def_map_get_map_wrapp(m)
    default.extend_map_check_with_map_check(m)
    if conf.do_nothing_if_fail then
        local n={}
        n.map=m.map
        n.cmap=m.cmap
        n.p=-1
        n.get_map=default.def_map_get_map_wrapp(n)
        n.filter=function () end
        n.check=function () return '' end
        default.extend_map_check_with_map_check(n)
        n.doc='autopairs close do nothing'
        return m,n
    end
    return m
end
return M
