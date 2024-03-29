local utils=require'ultimate-autopair.utils'
local M={}
---@type prof.def.m_type
M.type_def={}
---@param obj core.module
---@param conf string[]|string
---@return boolean
function M.get_type_opt(obj,conf)
    if type(conf)~='table' then conf={conf} end
    local tbl=obj[M.type_def]
    if not tbl then return false end
    for _,i in ipairs(conf) do
        for _,v in ipairs(tbl) do
            if v==i then return true end
        end
    end
    return false
end
---@param extension_name string
---@return table
function M.load_extension(extension_name)
    if type(extension_name)=='table' then return extension_name end
    return require('ultimate-autopair.extension.'..extension_name)
end
---@param _ prof.def.module
---@return core.filter-fn
function M.def_filter_wrapp(_)
    return function(_) return true end
end
---@param m prof.def.m.pair
---@param q prof.def.q
---@return core.get_map-fn
function M.def_pair_get_map_wrapp(m,q)
    return function(mode)
        if (mode=='i' and q.map) or (mode=='c' and q.cmap) then
            return {m.key}
        end
    end
end
---@param m prof.def.m.map
---@return core.get_map-fn
function M.def_map_get_map_wrapp(m)
    local map=type(m.map)=='table' and m.map or {m.map}
    ---@cast map string[]
    local cmap=type(m.cmap)=='table' and m.cmap or {m.cmap}
    ---@cast cmap string[]
    return function(mode)
        if (mode=='i' and m.map) then return map
        elseif (mode=='c' and m.cmap) then return cmap end
    end
end
---@type core.sort-fn
function M.def_pair_sort(a,b)
    if not (M.get_type_opt(a,'pair') and M.get_type_opt(b,'pair')) then return end
    ---@cast a prof.def.m.pair
    ---@cast b prof.def.m.pair
    if #a.pair~=#b.pair then return #a.pair>#b.pair end
    if M.get_type_opt(a,'start')
        and M.get_type_opt(b,'end') then
        return false
    elseif M.get_type_opt(a,'end')
        and M.get_type_opt(b,'start') then
        return true
    end
end
---@param m prof.def.m.pair
---@param q prof.def.q
---@param filter? fun(o:core.o):boolean
function M.extend_pair_check_with_map_check(m,q,filter)
    local check=m.check
    m.check=function (o)
        if ((o.key~=m.key and o.key~='') or not ((o.mode=='c' and q.cmap) or (o.mode=='i' and q.map))) or not (not filter or filter(o)) then return end
        return check(o)
    end
end
---@param m prof.def.m.map
---@param filter? fun(o:core.o):boolean
function M.extend_map_check_with_map_check(m,filter)
    ---@diagnostic disable-next-line: param-type-mismatch
    local map=vim.tbl_map(utils.keycode,type(m.map)=='table' and m.map or {m.map})
    ---@cast map string[]
    ---@diagnostic disable-next-line: param-type-mismatch
    local cmap=vim.tbl_map(utils.keycode,type(m.cmap)=='table' and m.cmap or {m.cmap})
    ---@cast cmap string[]
    local keyc=#cmap>0 and cmap or map
    local check=m.check
    m.check=function (o)
        if not (not filter or filter(o)) then return end
        if not ((o.mode=='c' and (vim.tbl_contains(keyc,o.key) or o.key==''))
            or (o.mode=='i' and (vim.tbl_contains(map,o.key) or o.key==''))) then
            return
        end
        return check(o)
    end
end
---@param m prof.def.m.map
function M.extend_map_check_in_oinit(m)
    local check=m.check
    m.check=function (o)
        if o.inoinit then
            return check(o)
        end
    end
end
---@param module prof.def.module
---@param fns function[]
---@return prof.def.pair.fn[]
function M.init_fns(module,fns)
    return vim.tbl_map(function(v)
        return function (...) return v(module,...) end
    end,fns)
end
---@param conf string[]|string
---@param o? core.o
---@return prof.def.module[]
function M.filter_for_opt(conf,o)
    if type(conf)=='string' then conf={conf} end
    local core=require'ultimate-autopair.core'
    return vim.tbl_filter(function (v) return M.get_type_opt(v,conf) end,(o and o.__core_mem and o.__core_mem()) or core.mem)
end
---@param m prof.def.module
---@param extensions prof.def.ext[]
function M.init_extensions(m,extensions)
    for _,i in ipairs(extensions) do
        if i.m.call then
            i.m.call(m,i)
        end
    end
end
---@param o core.o
---@param col number
---@param prev boolean?
---@param filter? fun(pair:prof.def.m.pair):boolean?
---@return prof.def.m.pair?
---@return number?
---@return number?
function M.get_pair_and_end_pair_pos_from_start(o,col,prev,filter)
    local spairs=M.get_pairs_by_pos(o,col,'start',not prev,filter)
    for _,i in ipairs(spairs) do
        local pcol,row=i.fn.find_corresponding_pair(o,col-(prev and #i.pair or 0))
        if pcol then return i,pcol,row end
    end
end
---@param o core.o
---@param col number
---@param prev boolean?
---@param filter? fun(pair:prof.def.m.pair):boolean?
---@return prof.def.m.pair?
---@return number?
---@return number?
function M.get_pair_and_start_pair_pos_from_end(o,col,prev,filter)
    local spairs=M.get_pairs_by_pos(o,col,'end',not prev,filter)
    for _,i in ipairs(spairs) do
        local pcol,row=i.fn.find_corresponding_pair(o,col-(prev and #i.pair or 0))
        if pcol then return i,pcol,row end
    end
end
---@param o core.o
---@param col number
---@param next boolean?
---@param type string?
---@param filter? fun(pair:prof.def.m.pair):boolean?
---@param nofilter boolean?
---@return prof.def.m.pair[]
function M.get_pairs_by_pos(o,col,type,next,filter,nofilter)
    type=type or 'pair'
    local ret={}
    for _,i in ipairs(M.filter_for_opt(type,o)) do
        ---@cast i prof.def.m.pair
        if ((not next and i.pair==o.line:sub(col-#i.pair,col-1)) or
            (next and i.pair==o.line:sub(col,col+#i.pair-1))) and
            (not filter or filter(i)) and (nofilter or i.filter(utils._get_o_pos(o,col-(next and 0 or #i.pair)))) then
            table.insert(ret,i)
        end
    end
    table.sort(ret,function (a,b)
        return a.p==b.p and #a.pair>#b.pair or a.p>b.p
    end)
    return ret
end
---@generic T,H
---@param opt T|fun(...:prof.def.optfn):T
---@param ... prof.def.optfn
---@return any
function M.orof(opt,...)
    if type(opt)=='function' then return opt(...) end
    return opt
end
return M
