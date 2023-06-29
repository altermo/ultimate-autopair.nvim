--Internal
local M={}
M.key_bs=vim.api.nvim_replace_termcodes('<bs>',true,true,true)
M.key_del=vim.api.nvim_replace_termcodes('<del>',true,true,true)
M.key_left=vim.api.nvim_replace_termcodes('<left>',true,true,true)
M.key_right=vim.api.nvim_replace_termcodes('<right>',true,true,true)
M.key_end=vim.api.nvim_replace_termcodes('<end>',true,true,true)
M.key_home=vim.api.nvim_replace_termcodes('<home>',true,true,true)
M.key_up=vim.api.nvim_replace_termcodes('<up>',true,true,true)
M.key_down=vim.api.nvim_replace_termcodes('<down>',true,true,true)
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
        return M.key_right:rep(num or 1)
    end
    return ('\aU'..M.key_right):rep(num or 1)
end
function M.moveh(num)
    if M.incmd() then
        return M.key_left:rep(num or 1)
    end
    return ('\aU'..M.key_left):rep(num or 1)
end
function M.getlinenr()
    return vim.fn.line('.')
end
function M.delete(pre,pos)
    return M.key_bs:rep(pre or 1)..M.key_del:rep(pos or 0)
end
function M.addafter(num,text,textlen)
    return M.movel(num)..text..M.moveh(num+(textlen or #text))
end
function M.gettsnode(linenr,col)
    if vim.treesitter.get_node then
        return vim.treesitter.get_node({bufnr=0,pos={linenr,col}})
    else
        return vim.treesitter.get_node_at_pos(0,linenr,col,{})
    end
end
return M
