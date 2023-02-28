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
    if M.incmd() then
        return vim.fn['repeat']('<right>',(num or 1))
    end
    return vim.fn['repeat']('\aU<right>',(num or 1))
end
function M.moveh(num)
    if M.incmd() then
        return vim.fn['repeat']('<left>',(num or 1))
    end
    return vim.fn['repeat']('\aU<left>',(num or 1))
end
function M.getlinenr()
    return vim.fn.line('.')
end
function M.delete(pre,pos)
    return vim.fn['repeat']('<bs>',pre or 1)..vim.fn['repeat']('<del>',pos or 0)
end
function M.addafter(num,text,textlen)
    return M.movel(num)..text..M.moveh(num+(textlen or #text))
end
function M.gettsnode(linenr,col)
    if vim.treesitter.get_node then
        return vim.treesitter.get_node({bufnr=0,pos={linenr,col}},{})
    else
        return vim.treesitter.get_node_at_pos(0,linenr,col,{})
    end
end
return M
