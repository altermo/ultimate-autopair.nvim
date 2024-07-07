local open_pair=require'ultimate-autopair._lib.open_pair' --TODO:make user be able to chose the open_pair detector (separately for open_pair/find_pair/...)
local utils=require'ultimate-autopair.utils'
local M={}
---@param o ua.info
---@param somepairs ua.prof.pair.pair[]
---@return ua.prof.pair.pair[]
function M.backwards_get_start_pairs(o,somepairs)
    local ret={}
    for _,v in ipairs(somepairs) do
        if v.type=='start'
            and v.start_pair_old==o.lines[o.row]:sub(o.col-#v.start_pair_old,o.col-1)
            and M.run_start_pair_filter(setmetatable({m=v,col=o.col-#v.start_pair_old},{__index=o}))
        then
            table.insert(ret,v)
        end
    end
    return ret
end
---@param o ua.info
---@param somepairs ua.prof.pair.pair[]
---@return ua.prof.pair.pair[]
function M.backwards_get_end_pairs(o,somepairs)
    local ret={}
    for _,v in ipairs(somepairs) do
        if v.type=='end'
            and v.end_pair_old==o.lines[o.row]:sub(o.col-#v.end_pair_old,o.col-1)
            and M.run_end_pair_filter(setmetatable({m=v,col=o.col-#v.end_pair_old},{__index=o}))
        then
            table.insert(ret,v)
        end
    end
    return ret
end
---@param o ua.info
---@param somepairs ua.prof.pair.pair[]
---@return ua.prof.pair.pair[]
function M.forward_get_end_pairs(o,somepairs)
    local ret={}
    for _,v in ipairs(somepairs) do
        if v.type=='end'
            and v.end_pair_old==o.lines[o.row]:sub(o.col,o.col+#v.end_pair_old-1)
            and M.run_end_pair_filter(setmetatable({m=v,col=o.col},{__index=o}))
        then
            table.insert(ret,v)
        end
    end
    return ret
end
---@param o ua.info
---@param somepairs ua.prof.pair.pair[]
---@return ua.prof.pair.pair[]
function M.forward_get_start_pairs(o,somepairs)
    local ret={}
    for _,v in ipairs(somepairs) do
        if v.type=='start'
            and v.start_pair_old==o.lines[o.row]:sub(o.col,o.col+#v.start_pair_old-1)
            and M.run_start_pair_filter(setmetatable({m=v,col=o.col},{__index=o}))
        then
            table.insert(ret,v)
        end
    end
    return ret
end
---@param o ua.info
---@return boolean
function M.pair_balansed_start(o)
    local m=o.m --[[@as ua.prof.pair.pair]]
    if m.start_pair_old==m.end_pair_old then
        return not open_pair.count_ambiguous_pair(o,'both')
    end
    local count=open_pair.count_start_pair(o)
    return not open_pair.count_start_pair(o,true,count,true)
end
---@param o ua.info
---@return boolean
function M.pair_balansed_end(o)
    local m=o.m --[[@as ua.prof.pair.pair]]
    if m.start_pair_old==m.end_pair_old then
        return not open_pair.count_ambiguous_pair(o,'both')
    end
    local count=open_pair.count_end_pair(o)
    return not open_pair.count_end_pair(o,true,count,true)
end
---@param o ua.info
function M.run_end_pair_filter(o)
    local m=o.m --[[@as ua.prof.pair.pair]]
    return utils.run_filters(m.end_pair_filter,o,nil,-#m.end_pair_old)
end
---@param o ua.info
function M.run_start_pair_filter(o)
    local m=o.m --[[@as ua.prof.pair.pair]]
    return utils.run_filters(m.start_pair_filter,o,nil,-#m.start_pair_old)
end
---@param o ua.info
---@return number?
---@return number?
function M.next_open_end_pair(o)
    local m=o.m --[[@as ua.prof.pair.pair]]
    if m.start_pair_old==m.end_pair_old then
        return open_pair.count_ambiguous_pair(o,true,0,true)
    end
    return open_pair.count_end_pair(o,true,0,true)
end
---@param o ua.info
---@return number?
---@return number?
function M.prev_open_start_pair(o)
    local m=o.m --[[@as ua.prof.pair.pair]]
    if m.start_pair_old==m.end_pair_old then
        return open_pair.count_ambiguous_pair(o,false,0,true)
    end
    return open_pair.count_start_pair(o,true,0,true)
end
---@param key string
---@param modes string[]
---@return ua.hook.hash[]
function M.create_hooks(key,modes)
    local hookutils=require'ultimate-autopair.hook.utils'
    local hooks={}
    for _,mode in ipairs(modes) do
        table.insert(hooks,hookutils.to_hash('map',key,mode))
    end
    return hooks
end
---@param conf {p:number?,map:string|table,modes:string[],enable:boolean?}
---@param obj table
---@return ua.object?
function M.create_obj(conf,obj)
    if not conf.enable then return end
    local maps=type(conf.map)=='table' and conf.map or {conf.map} --[[@as table]]
    local hooks={}
    for _,map in ipairs(maps) do
        vim.list_extend(hooks,M.create_hooks(map,conf.modes))
    end
    return vim.tbl_extend('error',{
        p=conf.p,
        hooks=hooks,
    },obj)
end
---@param extensions table<string,table>
---@param o ua.info
---@return ua.actions?
function M.run_extension(extensions,o)
    local m=o.m --[[@as ua.prof.pair.pair]]
    for extname,conf in pairs(extensions) do
        local ext=require('ultimate-autopair.profile.pair.extension.'..extname)
        if m.type==ext.type then
            local ret=ext.run(o,conf)
            if ret then return ret end
        end
    end
end
---@param objects ua.instance
---@return ua.prof.pair.pair[]
function M.get_pairs(objects)
    assert(objects._cache)
    if objects._cache[M.get_pairs] then
        return objects._cache[M.get_pairs]
    end
    local ret={}
    for _,obj in ipairs(objects) do
        ---@cast obj ua.prof.pair.pair
        if obj.ispair then
            table.insert(ret,obj)
        end
    end
    objects._cache[M.get_pairs]=ret
    return ret
end
function M.get_opt(opt,...)
    if type(opt)=='function' then
        return opt(...)
    end
    return opt
end
return M
