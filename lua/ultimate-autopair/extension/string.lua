---F
local M={}
local default=require'ultimate-autopair.profile.default.utils'
M.savetype={}
---@param o core.o
---@param col number
---@param node string
---@return number?
---@return number?
function M._in_tsnode(o,col,row,node)
    col=col+o._coloffset(col,row)
end
---@param o core.o
---@param conf table
---@return number?
---@return number?
function M.instring(o,conf)
    for _,i in ipairs(default.filter_for_opt({'pairo','pair'})) do
        ---@cast i prof.def.m.pair
        if not i.conf.string or not i.fn.in_pair then goto continue end
        local start,_end=i.fn.in_pair(o,o.col) --TODO: o.col is worng if utf-8
        if start then return start,_end end
        ::continue::
    end
    for _,i in ipairs(conf.tsnode or {}) do
        local start,_end=M._in_tsnode(o,o.col,i)
        if start then return start,_end end
    end
end
---@param o core.o
---@param save table
---@param conf table
---@return boolean?
function M.filter(o,save,conf)
    if save.stringstart then
        return o.col>=save.stringstart and o.col<=save.stringend
    end
    for _,i in ipairs(default.filter_pair_type({'pairo','pair'})) do
        if i.conf.string and i.fn.in_pair and
            i.fn.in_pair(o,o.col) and i.fn.in_pair(o,o.col+1) then
            return
        end
    end
    _=conf
    return true
end
---@param m prof.def.module
---@param ext prof.def.ext
function M.call(m,ext)
    local check=m.check
    local conf=ext.conf
    m.check=function (o)
        local save={}
        o.save[M.savetype]=save
        save.currently_filtering=true
        save.stringstart,save.stringend=M.inserting(o,conf)
        save.currently_filtering=nil
        return check(o)
    end
    local filter=m.filter
    m.filter=function(o)
        local save=o.save[M.save_type]
        if not save or save.currently_filtering then return filter(o) end
        save.currently_filtering=true
        if M.filter(o,save,conf) then
            save.currently_filtering=nil
            return filter(o)
        end
        save.currently_filtering=nil
    end
end
--TODO: continue
return M
