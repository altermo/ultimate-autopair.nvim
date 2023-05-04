local M={}
M.type_pair={}
M.get_type_opt=function(obj,conf)
    local tbl=vim.tbl_get(obj._type or {},M.type_pair)
    if tbl then
        return vim.tbl_contains(tbl,conf)
    end
end
M.sort=function (a,b)
    if M.get_type_opt(a,'pair') and M.get_type_opt(b,'pair') then
        return #a.pair>#b.pair
    end
end
M.get_map_wrapper=function (modes,...)
    local args={...}
    return function(mode)
        if vim.tbl_contains(modes,mode) then
            return args
        end
    end
end
M.get_mode_map_wrapper=function(key,keyc)
    return function(mode)
        if mode=='i' and key then
            return {key}
        end
        if mode=='c' and keyc then
            return {keyc}
        end
    end
end
M.load_extension=function (extension_name)
    return vim.F.npcall(require,'ultimate-autopair.extensions.'..extension_name) or
        {call=function (...) end} --TODO
end
M.prepare_extensions=function (extensions)
    local exts={}
    for k,v in pairs(extensions or {}) do
        table.insert(exts,{k=k,v=v})
    end
    table.sort(exts,function (a,b) return a.v.p<b.v.p end)
    local ret={}
    for _,i in ipairs(exts) do
        table.insert(ret,{m=M.load_extension(i.k),name=i.k,conf=i.v})
    end
    return ret
end
function M.init_extensions(m,extensions)
    for _,i in ipairs(extensions) do
        i.m.call(m,i)
    end
end
function M.wrapp_old_extension(f,I)
    local ext=I or {}
    ext.call=function (m,extension)
        local map_type
        local typ
        if M.get_type_opt(m,'start') then
            typ='start'
            map_type=1
        elseif M.get_type_opt(m,'end') then
            typ='end'
            map_type=2
        elseif M.get_type_opt(m,'ambigous-start') then
            typ='start'
            map_type=3
        elseif M.get_type_opt(m,'ambigous-end') then
            typ='end'
            map_type=3
        else
            return
        end
        local check=m.check
        function m.check(o)
            local ret=f(o,m.conf,extension.conf,map_type,m)
            if type(ret)=='string' then
                return ret
            elseif ret==2 then
                return
            elseif ret==3 and typ=='start' then
                return
            elseif ret==4 and typ=='end' then
                return
            end
            return check(o)
        end
    end
    return ext
end
function M.filter_pair_type(conf)
    if type(conf)=='string' then conf={conf} end
    if type(conf)=='nil' then conf={'pair'} end
    local core=require'ultimate-autopair.core'
    return vim.tbl_filter(function (v)
        for _,i in ipairs(conf) do
            if M.get_type_opt(v,i) then return true end
        end
    end,core.mem)
end
function M.get_pair(pair)
    --TODO: a version which takes (line,col) (and a reverse version)
    for _,v in ipairs(M.filter_pair_type()) do
        if v.pair==pair then return v end
    end
end
function M.select_opt(...)
    for _,v in pairs({...}) do
        if v~=nil then
            return v
        end
    end
end
function M.key_check_cmd(o,key,normal,cmd,keyc)
    if o.incmd then
        return cmd and o.key==(keyc or key)
    end
    return normal and o.key==key
end
return M
