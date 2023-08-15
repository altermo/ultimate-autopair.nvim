---FI
local utils=require'ultimate-autopair.utils'
local M={}
M.savetype={}
---@param o core.o
---@param nodetypes string[]
---@return TSNode?
function M._in_tsnode(o,nodetypes)
    local node=utils.gettsnode(o)
    local function fn(n)
        local _,startcol,_=n:start()
        return startcol+1==o.col+o._coloffset(o.col,o.row)
    end
    while node and (not vim.tbl_contains(nodetypes,node:type()) or fn(node)) do
        node=node:parent()
    end
    if (not node) or fn(node) then return end
    return node
end
function M._in_tree(o)
    --TODO: move to utils
    local linenr,col=o.row+o._offset(o.row)-1,o.col+o._coloffset(o.col,o.row)-1
    if not o.save[M._in_tree] then o.save[M._in_tree]={} end
    local cache=o.sav[M._in_tree]
    if cache.no_parser then return end
    if cache[tostring(linenr)..';'..tostring(col)] then
        return cache[tostring(linenr)..';'..tostring(col)]
    end
    local stat,parser=pcall(vim.treesitter.get_parser)
    if not stat then
        (cache or {}).no_parser=true
        return
    end
    local pos={linenr,col,linenr,col}
    local langs=M._langauges_for_range(parser,pos)
    return langs
end
---@overload fun(self:LanguageTree,range:Range4):LanguageTree[]
function M._langauge_for_range(self,range,_s)
    _s=_s or {}
    table.insert(_s,1,self)
    for _, child in pairs(self._children) do
        if child:contains(range) then
            return M._langauge_for_range(child,range,_s)
        end
    end
    return _s
end
---@param o core.o
---@return table
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
---@param save table
function M.set_in_node_or_lang(o,conf,save)
    --TODO: implement lang
    local node=M._in_tsnode(o,conf.seperate)
    if node then
        local srow,scol,erow,ecol=utils.gettsnodepos(node,o)
        save.scol=scol+1
        save.srow=srow+1
        save.ecol=ecol
        save.erow=erow+1
        save.in_node=true
    end
end
---@param o core.o
---@param save table
---@param conf table
---@return boolean?
function M.filter(o,save,conf)
    if save.in_node then
        if o.row<save.srow then return end
        if o.row>save.erow then return end
        if o.row==save.srow and o.col<save.scol then return end
        if o.row==save.erow and o.col>save.ecol then return end
        return true
    end
    local node=M._in_tsnode(o,conf.seperate)
    if node then
        local srow,scol,erow,ecol=utils.gettsnodepos(node,o)
        if vim.tbl_contains({'string','raw_string'},node:type()) and erow+1==o.row and ecol==o.col then return true end --TODO: hack
        --TODO: maybe offset by one
        return false
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
        M.set_in_node_or_lang(o,conf,save)
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
