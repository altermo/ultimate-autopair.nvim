local utils=require'ultimate-autopair.utils'
local M={}
function M.check(m,ext,o)
    local node=utils.gettsnode(o.linenr-1,o.col-2)
    if o.col==1 then
        node=utils.gettsnode(o.linenr-1,o.col-1)
    end
    if not node then return end
    if o.col==1 and node:start()>=o.linenr-1 then return end
    local ntype=node:type()
    return (m.conf.tsnode_inside and not vim.tbl_contains(m.conf.tsnode_inside or {},ntype))
        or (vim.tbl_contains(m.conf.tsnode_outside or {},ntype))
        or (ext.conf.inside and not vim.tbl_contains(ext.conf.inside or {},ntype))
        or (vim.tbl_contains(ext.conf.outside or {},ntype))
end
function M.call(m,ext)
    local check=m.check
    m.check=function (o)
        if not o.incmd and M.check(m,ext,o) then return end
        return check(o)
    end
    if ext.conf.filter then
        local filter=m.filter
        m.filter=function(o)
            --TODO: option to only filter outside of tsnode, but don't disable
            --TODO: option to only filter insde of tsnode, but don't disable
            if not o.incmd and M.check(m,ext,o) then return end
            return filter(o)
        end
    end
end
return M
