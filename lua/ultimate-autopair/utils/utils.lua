local M={}
function M.incmd()
    return vim.fn.mode()=='c'
end
function M.getline(linenr)
    if M.incmd() then
        return vim.fn.getcmdline()
    else
        linenr=linenr or M.getlinenr()
        return vim.api.nvim_buf_get_lines(0,linenr-1,linenr,false)[1]
    end
end
function M.getcol()
    if M.incmd() then
        return vim.fn.getcmdpos()
    else
        return vim.fn.col('.')
    end
end
function M.movel(num)
    return vim.fn['repeat']('<right>',(num or 1))
end
function M.moveh(num)
    return vim.fn['repeat']('<left>',(num or 1))
end
function M.getlinenr()
    return vim.fn.line('.')
end
function M.getindent(linenr)
    return vim.fn.indent(linenr)
end
function M.getindentsize()
    return vim.fn.shiftwidth()
end
function M.delete(pre,pos)
    return vim.fn['repeat']('<bs>',pre or 1)..vim.fn['repeat']('<del>',pos or 0)
end
function M.completeabbr()
    return '\x1d'
end
return M
