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
function M.def_filter_wrapper(_)
    return function(_) return true end
end
---@param m prof.def.m.pair
---@param q prof.def.q
---@return core.get_map-fn
function M.def_pair_get_map_wrapper(m,q)
    return function(mode)
        if (mode=='i' and q.map) or (mode=='c' and q.cmap) then
            return {m.key}
        end
    end
end
---@param m prof.def.m.map
---@return core.get_map-fn
function M.def_map_get_map_wrapper(m)
    return function(mode)
        if (mode=='i' and m.map) then
            return type(m.map)=='table' and m.map or {m.map} --[[@as string[] ]]
        elseif (mode=='c' and m.cmap) then
            return type(m.cmap)=='table' and m.cmap or {m.cmap} --[[@as string[] ]]
        end
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
function M.extend_pair_check_with_map_check(m)
    local check=m.check
    m.check=function (o)
        if o.key~=m.key then return end
        return check(o)
    end
end
---@param m prof.def.m.map
function M.extend_map_check_with_map_check(m)
    local check=m.check
    m.check=function (o)
        local key=type(m.map)=='table' and m.map or {m.map}
        ---@cast key string[]
        local keyc=m.cmap and (type(m.cmap)=='table' and m.cmap or {m.cmap}) or key
        ---@cast keyc string[]
        if not ((o.incmd and vim.tbl_contains(keyc,o.key))
            or (not o.incmd and vim.tbl_contains(key,o.key))) then
            return
        end
        return check(o)
    end
end
---@generic T
---@param module prof.def.module
---@param fns fun(m:prof.def.module,T)[]
---@return fun(T)[]
function M.init_fns(module,fns)
    return vim.tbl_map(function(v)
        return function (...) return v(module,...) end
    end,fns)
end
---@param conf string[]|string
---@return prof.def.module[]
function M.filter_for_opt(conf)
    if type(conf)=='string' then conf={conf} end
    local core=require'ultimate-autopair.core'
    return vim.tbl_filter(function (v) return M.get_type_opt(v,conf) end,core.mem)
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
return M
