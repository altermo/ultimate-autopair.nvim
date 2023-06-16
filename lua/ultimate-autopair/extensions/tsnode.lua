local utils=require'ultimate-autopair.utils'
local M={}
function M.check(m,ext,o)
    local err,node=pcall(utils.gettsnode,o.linenr-1,o.col-2)
    if o.col==1 then
        err,node=pcall(utils.gettsnode,o.linenr-1,o.col-1)
    end
    if not err then return end
    if not node then return end
    if o.col==1 and node:start()>=o.linenr-1 then return end
    local ntype=node:type()
    return (m.conf.tsnode_inside and not vim.tbl_contains(m.conf.tsnode_inside or {},ntype))
        or (vim.tbl_contains(m.conf.tsnode_outside or {},ntype))
        or (ext.conf.inside and not vim.tbl_contains(ext.conf.inside or {},ntype))
        or (vim.tbl_contains(ext.conf.outside or {},ntype))
    --TODO: filtering; requires: in_tsnode_map
end
function M.call(m,ext)
    local check=m.check
    m.check=function (o)
        if M.check(m,ext,o) then return end
        return check(o)
    end
end
return M
