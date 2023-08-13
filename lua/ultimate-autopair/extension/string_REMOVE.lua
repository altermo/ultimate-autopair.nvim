---F
local M={}
local default=require'ultimate-autopair.profile.default.utils'
local utils=require'ultimate-autopair.utils'
M.savetype={}
---@param o core.o
---@param nodetype string
---@return number?
---@return number?
---@return number?
---@return number?
function M._in_tsnode(o,nodetype)
    local node=utils.gettsnode(o)
    if not node then return end
    if node:parent() and node:parent():type()==nodetype then
        node=node:parent() --[[@as TSNode]]
    end
    if node:type()~=nodetype then return end
    local _,startcol,_=node:start()
    if startcol+1==o.col+o._coloffset(o.col,o.row) then return end
    local srow,scol,erow,ecol=utils.gettsnodepos(node,o)
    return scol+1,ecol,srow+1,erow+1
end
---@param o core.o
---@return {cache:table,currently_filtering:table?,[string]:any}
function M.get_save(o)
    local save=o.save[M.savetype]
    if not save then
        save={
            cache={},
        }
        o.save[M.savetype]=save
    end
    return save
end
---@param o core.o
---@param conf table
---@return number?
---@return number?
---@return number?
---@return number?
function M.instring(o,conf)
    ---TODO: cache
    ---TODO fix: '"|"' > "|" but should '"|"'
    ---TODO: a way of recursive string detection as "'" | "'", detected as in string '" | "'
    local save=M.get_save(o)
    for _,i in ipairs(conf.tsnode or {}) do
        local start,_end,startrow,endrow=M._in_tsnode(o,i)
        if start then
            return start,_end,startrow,endrow
        end
    end
    if conf.nopair then return end
    local currently_filtering=save.currently_filtering
    save.currently_filtering=save.currently_filtering or {}
    for _,i in ipairs(default.filter_for_opt({'pair'})) do
        ---@cast i prof.def.m.pair
        if not i.conf.string or not i.fn.in_pair then goto continue end
        if (currently_filtering or {})[i] then goto continue end
        save.currently_filtering[i]=true
        local start,_end,startrow,endrow=i.fn.in_pair(o,true)
        save.currently_filtering[i]=nil
        if start then
            save.currently_filtering=currently_filtering
            return start,_end,startrow,endrow
        end
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
        local save=M.get_save(o)
        o.save[M.savetype]=save
        save.stringstart,save.stringend,save.stringrowstart,save.stringrowsend=M.instring(o,conf)
        return check(o)
    end
    local filter=m.filter
    m.filter=function(o)
        local save=M.get_save(o)
        if M.filter(o,save,conf) then
            return filter(o)
        end
    end
end
return M
