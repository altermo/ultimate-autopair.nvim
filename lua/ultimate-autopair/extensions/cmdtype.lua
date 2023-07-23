local M={}
function M.check(_,m,ext)
    if vim.tbl_contains(ext.conf.types,vim.fn.getcmdtype()) then
        return true
    end
    if m.conf.cmdtype and vim.tbl_contains(m.conf.cmdtype,vim.fn.getcmdtype()) then
        return true
    end
end
function M.call(m,ext)
    local check=m.check
    m.check=function (o)
        if M.check(o,m,ext) then return end
        return check(o)
    end
end
return M
