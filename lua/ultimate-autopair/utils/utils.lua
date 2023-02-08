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
function M.setline(line,linenr)
    if M.incmd() then
        local pos=vim.fn.getcmdpos()
        vim.fn.setcmdline(line,pos)
    else
        linenr=linenr or M.getlinenr()
        vim.api.nvim_buf_set_lines(0,linenr-1,linenr,false,{line})
    end
end
function M.getcol()
    if M.incmd() then
        return vim.fn.getcmdpos()
    else
        return vim.fn.col('.')
    end
end
function M.setcursor(col,linenr)
    if M.incmd() then
        vim.api.nvim_feedkeys('\x80kh'..vim.fn['repeat']('\x80kr',col-1),'n',{})
    else
        vim.fn.cursor{linenr or 0,col}
    end
end
function M.movel(num)
    return vim.fn['repeat']('<right>',(num or 1))
end
function M.moveh(num)
    return vim.fn['repeat']('<left>',(num or 1))
end
function M.insert(text,line,col)
    line=line:sub(1,col-1)..text..line:sub(col)
    M.setline(line)
end
function M.append(text)
    M.insert(text,M.getline(),M.getcol())
    M.movel(#text)
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
function M.appendline(line,conf)
    if M.incmd() then error() end
    local indent=conf.indent or M.getindent()
    local cursor=conf.cursor
    local linenr=conf.linenr or M.getlinenr()
    if vim.o.expandtab then
        line=vim.fn['repeat'](' ',indent)..line
    else
        line=vim.fn['repeat']('\t',indent/vim.fn.shiftwidth())..line
        line=vim.fn['repeat'](' ',indent%vim.fn.shiftwidth())..line
    end
    vim.api.nvim_buf_set_lines(0,linenr,linenr,false,{line})
    if cursor=='last' then
        vim.fn.cursor{linenr+1,#M.getline(linenr+1)+2}
    elseif cursor=='vert' then
        vim.fn.cursor{linenr+1,M.getcol()}
    end
end
return M
