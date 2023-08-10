---F
local M={}
local default=require'ultimate-autopair.profile.default.utils'
local utils=require'ultimate-autopair.utils'
M.savetype={}
---@param o core.o
---@param nodetype string
---@return number?
---@return number?
function M._in_tsnode(o,nodetype)
    local node=utils.gettsnode(o)
    if not node then return end
    if node:parent() and node:parent():type()==nodetype then
        node=node:parent()
    end
    if node:type()~=nodetype then return end
    local linenr=o.row+o._offset(o.row)
    local rs,start,_=node:start()
    if rs+1<linenr then start=0 end
    if start+1==o.col+o._coloffset(o.col,o.row) then return end
    local re,end_,_=node:end_()
    if re+1>linenr then end_=#o.line end
    return start+1,end_
end
---@param o core.o
---@param conf table
---@return number?
---@return number?
function M.instring(o,conf)
    ---TODO: cache
    ---TODO fix: '"|"' > "|" but should '"|"'
    ---TODO: implement multi_row return value, needs: in_pair and count_ambigous_pair to return row
    ---TODO: a way of recursive string detection as "'" | "'", detected as in string '" | "'
    for _,i in ipairs(conf.tsnode or {}) do
        local start,_end=M._in_tsnode(o,i)
        if start then return start,_end end
    end
    for _,i in ipairs(default.filter_for_opt({'pair'})) do
        ---@cast i prof.def.m.pair
        if not i.conf.string or not i.fn.in_pair then goto continue end
        local start,_end=i.fn.in_pair(o)
        if start then return start,_end end
        ::continue::
    end
end
---@param o core.o
---@param save table
---@param conf table
---@return boolean?
function M.filter(o,save,conf)
    if save.stringstart then
        return o.col>=save.stringstart and o.col<=save.stringend
            and o.row>=save.stringrowstart and o.row<=save.stringrowsend
    end
    local start,end_=M.instring(o,conf)
    if start and end_>o.col then
        return
    end
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
        save.stringstart,save.stringend=M.instring(o,conf)
        save.stringrowstart,save.stringrowsend=o.row,o.row
        save.currently_filtering=nil
        return check(o)
    end
    local filter=m.filter
    m.filter=function(o)
        local save=o.save[M.savetype]
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
