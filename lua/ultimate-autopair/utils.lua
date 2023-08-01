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
function M.getlines()
    --TODO: only load the necessary lines and cache for like 100 (+ maybe depending on line length)
    if M.incmd() then
        return {M.getline()}
    end
    return vim.api.nvim_buf_get_lines(0,0,-1,false)
end
function M.getline(linenr)
    if M.incmd() then
        return vim.fn.getcmdline()
    end
    linenr=linenr or M.getlinenr()
    return vim.api.nvim_buf_get_lines(0,linenr-1,linenr,false)[1]
end
function M.getcol()
    if M.incmd() then
        return vim.fn.getcmdpos()
    end
    return vim.fn.col('.')
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
    if M.incmd() then
        return 1
    end
    return vim.fn.line('.')
end
function M.delete(pre,pos)
    return M.key_bs:rep(pre or 1)..M.key_del:rep(pos or 0)
end
function M.addafter(num,text,textlen)
    return M.movel(num)..text..M.moveh(num+(textlen or #text))
end
function M.gettsnode(linenr,col,cache)
    if cache and not not cache[M.gettsnode] then cache[M.gettsnode]={} end --TODO: write better
    if cache then cache=cache[M.gettsnode] end --TODO: write better
    if cache and cache.no_parser then return end
    if cache and cache[tostring(linenr)..';'..tostring(col)] then
        return cache[tostring(linenr)..';'..tostring(col)] or nil
    end
    if not pcall(vim.treesitter.get_parser,0) then
        (cache or {}).no_parser=true
        return
    end
    local s,ret
    if vim.treesitter.get_node then
        s,ret=pcall(vim.treesitter.get_node,{bufnr=0,pos={linenr,col}})
    else
        ---@diagnostic disable-next-line: deprecated
        s,ret=pcall(vim.treesitter.get_node_at_pos,0,linenr,col,{})
    end
    if not s then ret=nil end
    if cache then
        cache[tostring(linenr)..';'..tostring(col)]=ret
    end
    return ret
end
function M.getsmartft(linenr,col,cache)
    if cache and not not cache[M.getsmartft] then cache[M.getsmartft]={} end --TODO: write better
    if cache then cache=cache[M.getsmartft] end --TODO: write better
    if cache and cache.no_parser then return vim.o.filetype end
    if cache and cache[tostring(linenr)..';'..tostring(col)] then
        return cache[tostring(linenr)..';'..tostring(col)] or vim.o.filetype
    end
    local stat,parser=pcall(vim.treesitter.get_parser,0)
    if not stat then
        (cache or {}).no_parser=true
        return vim.o.filetype
    end
    local pos={linenr,col,linenr,col}
    local ret=parser:language_for_range(pos):lang()
    if ret=='markdown_inline' then ret='markdown' end
    if cache then
        cache[tostring(linenr)..';'..tostring(col)]=ret
    end
    return ret
end
return M
