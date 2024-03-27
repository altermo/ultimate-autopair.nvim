local open_pair=require'ultimate-autopair._lib.open_pair' --TODO:make user be able to chose the open_pair detector (separately for open_pair/find_pair/...)
local utils=require'ultimate-autopair.utils'
local M={}
---@param o ua.info
---@param somepairs ua.prof.def.pair[]
---@return ua.prof.def.pair[]
function M.backwards_get_start_pairs(o,somepairs)
    local ret={}
    for _,v in ipairs(somepairs) do
        if v.info.type=='start'
            and v.info.start_pair==o.line:sub(o.col-#v.info.start_pair,o.col-1)
            and M.run_start_pair_filter(setmetatable({m=v,col=o.col-#v.info.start_pair},{__index=o}))
        then
            table.insert(ret,v)
        end
    end
    return ret
end
---@param o ua.info
---@param somepairs ua.prof.def.pair[]
---@return ua.prof.def.pair[]
function M.backwards_get_end_pairs(o,somepairs)
    local ret={}
    for _,v in ipairs(somepairs) do
        if v.info.type=='end'
            and v.info.end_pair==o.line:sub(o.col-#v.info.end_pair,o.col-1)
            and M.run_end_pair_filter(setmetatable({m=v,col=o.col-#v.info.end_pair},{__index=o}))
        then
            table.insert(ret,v)
        end
    end
    return ret
end
---@param o ua.info
---@return boolean
function M.pair_balansed_start(o)
    local info=(o.m --[[@as ua.prof.def.pair]]).info
    if info.start_pair==info.end_pair then
        return not open_pair.count_ambiguous_pair(o,'both')
    end
    local count=open_pair.count_start_pair(o)
    return not open_pair.count_start_pair(o,true,count,true)
end
---@param o ua.info
---@return boolean
function M.pair_balansed_end(o)
    local info=(o.m --[[@as ua.prof.def.pair]]).info
    if info.start_pair==info.end_pair then
        return not open_pair.count_ambiguous_pair(o,'both')
    end
    local count=open_pair.count_end_pair(o)
    return not open_pair.count_end_pair(o,true,count,true)
end
---@param o ua.info
---@param col number?
function M.run_end_pair_filter(o,col)
    col=col or o.col
    local info=(o.m --[[@as ua.prof.def.pair]]).info
    return utils.run_filters(info.end_pair_filter,o,nil,-#info.end_pair)
end
---@param o ua.info
function M.run_start_pair_filter(o)
    local info=(o.m --[[@as ua.prof.def.pair]]).info
    return utils.run_filters(info.start_pair_filter,o,nil,-#info.start_pair)
end
---@param o ua.info
---@return number?
---@return number?
function M.next_open_end_pair(o)
    local info=(o.m --[[@as ua.prof.def.pair]]).info
    if info.start_pair==info.end_pair then
        return open_pair.count_ambiguous_pair(o,true,0,true)
    end
    return open_pair.count_end_pair(o,true,0,true)
end
---@param o ua.info
---@return number?
---@return number?
function M.prev_open_start_pair(o)
    local info=(o.m --[[@as ua.prof.def.pair]]).info
    if info.start_pair==info.end_pair then
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
        table.insert(hooks,hookutils.to_hash('map',key,{mode=mode}))
    end
    return hooks
end
---@param conf {p:number?,map:string|table,modes:string[],enable:boolean?}
---@param obj table
---@return ua.object?
function M.create_obj(conf,obj)
    if type(conf.map)=='table' then
        error('Not implemented')
    end
    if not conf.enable then return end
    return vim.tbl_extend('error',{
        p=conf.p,
        hooks=M.create_hooks(conf.map --[[@as string]],conf.modes)
    },obj)
end
---@param extensions table<string,table>
---@param o ua.info
---@return ua.actions?
function M.run_extension(extensions,o)
    local info=(o.m --[[@as ua.prof.def.pair]]).info
    for extname,conf in pairs(extensions) do
        local ext=require('ultimate-autopair.profile.pair.extension.'..extname)
        if info.type==ext.type then
            local ret=ext.run(o,conf)
            if ret then return ret end
        end
    end
end
return M
