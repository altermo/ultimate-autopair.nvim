local M={}
M.type_pair={}
M.sort=function (a,b)
    if vim.tbl_contains(a._type or {},M.type_pair) and vim.tbl_contains(b._type or {},M.type_pair) then
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
M.load_extension=function (extension_name)
    return vim.F.npcall(require,'ultimate_autopair_extensions.'..extension_name) or
        {call=function (...) end} --TODO
end
M.prepare_extensions=function (extensions)
    local exts={}
    for k,v in pairs(extensions) do
        table.insert(exts,{k=k,v=v})
    end
    table.sort(exts,function (a,b) return a.v.p<b.v.p end)
    local ret={}
    for _,i in ipairs(exts) do
        table.insert(ret,{m=M.load_extension(i.k),name=i.k,conf=i.v})
    end
    return ret
end
M.run_extensions=function (m,o,map_type)
    o.wline=o.line
    o.wcol=o.col
    local flag_dont_start_pair
    local flag_dont_end_pair
    for _,i in ipairs(m.extensions) do
        if (not m.conf.check) or m.conf.check(m,o,map_type) then
            local ret=i.m.call(o,m.conf,i.conf,map_type,m)
            if ret then
                if ret==2 then return {dont_pair=true}
                elseif ret==3 then flag_dont_start_pair=true
                elseif ret==4 then flag_dont_end_pair=true
                else
                    return ret
                end
            end
        end
    end
    return {
        dont_start_pair=flag_dont_start_pair,
        dont_end_pair=flag_dont_end_pair,
    }
end
function M.filter_pair_type()
    local core=require'ultimate-autopair.core'
    core.I.sort()
    return vim.tbl_filter(function (v)
        return vim.tbl_contains(v._type or {},M.type_pair)
    end,core.mem)
end
function M.get_pair(pair)
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
return M
