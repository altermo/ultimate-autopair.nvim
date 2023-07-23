local M={}
M.save_type={}
local default=require'ultimate-autopair.configs.default.utils'
function M.instring(o,save,conf)
    for _,i in ipairs(default.filter_pair_type({'pairo','pair'})) do
        if not i.conf.string or not i.fn.in_pair then goto continue end
        local isin,start,_end=i.fn.in_pair(o,o.col,{notree=conf.notree,linenr=o.linenr,cache=save.cache})
        if isin then return isin,start,_end end
        ::continue::
    end
end
function M.filter(o,save,conf)
    if save.instring then
        return o.col>=save.stringstart and o.col<=save.stringend
    end
    for _,i in ipairs(default.filter_pair_type({'pairo','pair'})) do
        if i.conf.string and i.fn.in_pair and
            i.fn.in_pair(o,o.col,{notree=conf.notree,linenr=o.linenr,cache=save.cache}) and i.fn.in_pair(o,o.col+1,{notree=conf.notree,linenr=o.linenr,cache=save.cache}) then
            return
        end
    end
    return true
end
function M.call(m,ext)
    local check=m.check
    m.check=function (o)
        local save={cache={}}
        o.save[M.save_type]=save
        save.currently_filtering=true
        save.instring,save.stringstart,save.stringend=M.instring(o,save,ext.conf)
        save.currently_filtering=nil
        return check(o)
    end
    local filter=m.filter
    m.filter=function(o)
        local save=o.save[M.save_type]
        if not save or save.currently_filtering then return filter(o) end
        save.currently_filtering=true
        if M.filter(o,save,ext.conf) then
            save.currently_filtering=nil
            return filter(o)
        end
        save.currently_filtering=nil
    end
end
return M
