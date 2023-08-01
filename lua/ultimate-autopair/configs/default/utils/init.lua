local M={}
M.type_pair={}
function M.get_type_opt(obj,conf)
    if type(conf)~='table' then conf={conf} end
    local tbl=obj[M.type_pair]
    if tbl then
        for _,i in ipairs(conf) do
            for _,v in ipairs(tbl) do
                if v==i then return true end
            end
        end
    end
end
function M.sort(a,b)
    if not (M.get_type_opt(a,'pair') and M.get_type_opt(b,'pair')) then return end
    if #a.pair~=#b.pair then return #a.pair>#b.pair end
    if M.get_type_opt(a,{'start','ambigous-start'})
        and M.get_type_opt(b,{'end','ambigous-end'}) then
        return false
    elseif M.get_type_opt(a,{'end','ambigous-end'})
        and M.get_type_opt(b,{'start','ambigous-start'}) then
        return true
    end
end
function M.get_mode_map_wrapper(key,keyc)
    return function(mode)
        if mode=='i' and key then
            return type(key)=='string' and {key} or key
        end
        if mode=='c' and keyc then
            return type(keyc)=='string' and {keyc} or keyc
        end
    end
end
function M.load_extension(extension_name)
    if type(extension_name)=='table' then return extension_name end
    return require('ultimate-autopair.extensions.'..extension_name)
end
function M.prepare_extensions(extensions)
    local exts={}
    for k,v in pairs(extensions or {}) do
        if v then
            table.insert(exts,{k=k,v=v})
        end
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
function M.filter_pair_type(conf)
    if type(conf)=='string' then conf={conf} end
    if type(conf)=='nil' then conf={'pair'} end
    local core=require'ultimate-autopair.core'
    return vim.tbl_filter(function (v) return M.get_type_opt(v,conf) end,core.mem)
end
function M.key_check_cmd(o,key,normal,cmd,keyc)
    key=type(key)=='string' and {key} or key
    keyc=keyc and (type(keyc)=='string' and {keyc} or keyc) or key
    if o.incmd then
        return cmd and vim.tbl_contains(keyc,o.key)
    end
    return normal and vim.tbl_contains(key,o.key)
end
function M.start_pair(col,o,next,check,all,nofilter)
    local pairs=M.get_pairs_by_pos(col,o.line,next)
    table.sort(pairs,function (a,b)
        return #a.pair>#b.pair
    end)
    local ret={}
    for _,i in ipairs(pairs) do
        if i.fn.is_start(o,next and col or col-#i.pair)
            and i.rule() and (not check or check(i)) and
            (nofilter or not i.filter or i.filter(vim.tbl_extend('force',o,{col=next and col or col-#i.pair}))) then
            if not all then
                return i
            end
            table.insert(ret,i)
        end
    end
    return all and ret
end
function M.end_pair(col,o,prev,check,all,nofilter)
    local pairs=M.get_pairs_by_pos(col,o.line,not prev)
    table.sort(pairs,function (a,b)
        return #a.pair>#b.pair
    end)
    local ret={}
    for _,i in ipairs(pairs) do
        if i.fn.is_end(o,prev and col-#i.pair or col)
            and i.rule() and (not check or check(i)) and
            (nofilter or not i.filter or i.filter(vim.tbl_extend('force',o,{col=prev and col-#i.pair or col}))) then
            if not all then
                return i
            end
            table.insert(ret,i)
        end
    end
    return all and ret
end
function M.get_pairs_by_pos(col,line,next)
    local ret={}
    for _,i in ipairs(M.filter_pair_type()) do
        if not next and i.pair==line:sub(col-#i.pair,col-1) then
            table.insert(ret,i)
        elseif next and i.pair==line:sub(col,col+#i.pair-1) then
            table.insert(ret,i)
        end
    end
    return ret
end
function M.init_fns(module,fns)
    return vim.tbl_map(function(v)
        return function (...) return v(module,...) end
    end,fns)
end
function M.init_check_map(m)
    local check=m.check
    m.check=function (o)
        o.save={}
        if not M.key_check_cmd(o,m.map,m.map,m.cmap,m.cmap) then return end
        if not m.rule() then return end
        return check(o)
    end
end
function M.init_check_pair(m,q)
    local check=m.check
    m.check=function (o)
        o.save={}
        if not M.key_check_cmd(o,m.key,q.map,q.cmap) then return end
        if not m.rule() then return end
        return check(o)
    end
end
function M.wrapp_pair_filter(o,filter)
    return function (pos1,pos2)
        if o._nofilter then return true end
        pos2=pos2 or pos1
        for i=pos1,pos2 do
            if not filter({
                line=o.line,
                --lines=o.lines,
                col=i,
                linenr=o.linenr,
                save=o.save,
            }) then
                return false
            end
        end
        return true
    end
end
return M
