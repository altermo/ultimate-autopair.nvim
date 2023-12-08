---FI
---@class ext.tsnode.conf:prof.def.ext.conf
---@field separate string[]|fun(...:prof.def.optfn):string[]
---@class ext.tsnode.save
---@field _skip? string[]|false
---@field in_node? TSNode
---@field srow? number
---@field erow? number
---@field scol? number
---@field ecol? number
---@field in_tree? boolean
----@field prev_node_ecol? number
----@field prev_node_erow? number

local utils=require'ultimate-autopair.utils'
local default=require'ultimate-autopair.profile.default.utils'
local M={}
M.savetype={}
---@param o core.o
---@param nodetypes string[]
---@param incheck? boolean
---@return TSNode?
function M._in_tsnode(o,nodetypes,incheck)
    --TODO fix: if incheck don't for one char after node
    ---PROBLEM: there are exceptions: comment #|
    ---SULUTION: make option to add exceptions
    local ssave=o.save[M._in_tsnode] or {} o.save[M._in_tsnode]=ssave
    local save=ssave[nodetypes] or {} ssave[nodetypes]=save
    if incheck then save={} end
    local node=utils.gettsnode(o)
    if not node then return end
    if node and save[node:id()] then return unpack(save[node:id()]) end
    local ql={}
    local cache={}
    local nsave=M.get_save(o)
    for _,v in ipairs(nodetypes) do
        if not nsave._skip or not vim.tbl_contains(nsave._skip,v) then
            ql[v]=true
        end
    end
    ---https://github.com/altermo/ultimate-autopair.nvim/issues/44
    while node:parent() and (not ql[node:type()] or (
        incheck and ({node:start()})[2]==o.col+o._coloffset(o.col,o.row)-1
        and ({node:start()})[1]==o.row+o._offset(o.row)-1)) do
        save[node:id()]=cache
        node=node:parent() --[[@as TSNode]]
        --TODO fix: TSNode:id() doesn't differ between trees
        if node and save[node:id()] then cache[1]=save[node:id()][1] return unpack(save[node:id()]) end
    end
    save[node:id()]=cache
    cache[1]=node
    return node
end
---@param o core.o
---@return ext.tsnode.save
function M.get_save(o)
    local save=o.save[M.savetype]
    if not save then
        save={}
        o.save[M.savetype]=save
    end
    return save
end
---@param o core.o
---@param conf ext.tsnode.conf
---@param save ext.tsnode.save
---@param m prof.def.module
function M.set_in_node(o,conf,save,m)
    local node=M._in_tsnode(o,default.orof(conf.separate,o,m,true),true)
    if node then
        local srow,scol,erow,ecol=utils.gettsnodepos(node,o)
        save.scol=scol
        save.srow=srow
        save.ecol=ecol
        save.erow=erow
        save.in_node=node
    end
end
---@param o core.o
---@param save ext.tsnode.save
---@param conf ext.tsnode.conf
---@param m prof.def.module
---@return boolean?
function M.filter(o,save,conf,m)
    if save.in_node then
        if o.row<save.srow then return end
        if o.row>save.erow then return end
        if o.row==save.srow and o.col<save.scol then return end
        if o.row==save.erow and o.col>save.ecol then return end
    end
    local node=M._in_tsnode(o,default.orof(conf.separate,o,m))
    local root
    if node and node~=(save.in_node or root) then
        local srow,scol,erow,ecol=utils.gettsnodepos(node,o)
        if vim.tbl_contains({'string','raw_string'},node:type()) and erow==o.row and ecol==o.col then return true end --HACK
        if vim.tbl_contains({'string','raw_string'},node:type()) and srow==o.row and scol==o.col then return true end --HACK
        return
    end
    return true
end
---@param m prof.def.module
---@param ext prof.def.ext
function M.call(m,ext)
    local check=m.check
    local conf=ext.conf
    ---@cast conf ext.tsnode.conf
    m.check=function (o)
        local save=M.get_save(o)
        M.set_in_node(o,conf,save,m)
        return check(o)
    end
    local filter=m.filter
    m.filter=function(o)
        local save=M.get_save(o)
        if save._skip==false or M.filter(o,save,conf,m) then
            return filter(o)
        end
    end
end
return M
