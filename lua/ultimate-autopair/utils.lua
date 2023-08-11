--Internal Utils
local M={}
M.maxlines=100
M.key_bs=vim.api.nvim_replace_termcodes('<bs>',true,true,true)
M.key_del=vim.api.nvim_replace_termcodes('<del>',true,true,true)
M.key_left=vim.api.nvim_replace_termcodes('<left>',true,true,true)
M.key_right=vim.api.nvim_replace_termcodes('<right>',true,true,true)
M.key_end=vim.api.nvim_replace_termcodes('<end>',true,true,true)
M.key_home=vim.api.nvim_replace_termcodes('<home>',true,true,true)
M.key_up=vim.api.nvim_replace_termcodes('<up>',true,true,true)
M.key_down=vim.api.nvim_replace_termcodes('<down>',true,true,true)
M.key_noundo=vim.api.nvim_replace_termcodes('<C-g>U',true,true,true)
---@param linenr? number
---@return string
function M.getline(linenr)
    if M.incmd() then
        return vim.fn.getcmdline()--[[@as string]]
    end
    linenr=linenr or M.getlinenr()
    return unpack(vim.api.nvim_buf_get_lines(0,linenr-1,linenr,false))
end
---@param start number
---@param end_ number
---@return string[]
function M._getlines(start,end_)
    return vim.api.nvim_buf_get_lines(0,start,end_,true)
end
---@return integer
---@return table
function M.getlines()
    if M.incmd() then
        return 1,{M.getline()}
    end
    local linenr=M.getlinenr()
    local linecount=M._getlinecount()
    if linecount<M.maxlines*2+1 then
        return linenr,M._getlines(0,-1)
    elseif linenr<M.maxlines+1 then
        return linenr,M._getlines(0,M.maxlines*2+1)
    elseif linenr>linecount-M.maxlines then
        return M.maxlines*2+linenr-linecount+1,M._getlines(-M.maxlines*2-2,-1)
    else
        return M.maxlines+1,M._getlines(linenr-M.maxlines-1,linenr+M.maxlines)
    end
end
---@return number
function M._getlinecount()
    if M.incmd() then
        return 1
    end
    return vim.fn.line('$')--[[@as number]]
end
---@return boolean
function M.incmd()
    return M.getmode()=='c'
end
---@param complex boolean?
---@return string
function M.getmode(complex)
    return vim.fn.mode(complex) --[[@as string]]
end
---@return number
function M.getcol()
    if M.incmd() then
        return vim.fn.getcmdpos()--[[@as number]]
    end
    return vim.fn.col('.')--[[@as number]]
end
---@param num? number
---@return string
function M.movel(num)
    if M.incmd() then
        return M.key_right:rep(num or 1)
    end
    return (M.key_noundo..M.key_right):rep(num or 1)
end
---@param num? number
---@return string
function M.moveh(num)
    if M.incmd() then
        return M.key_left:rep(num or 1)
    end
    return (M.key_noundo..M.key_left):rep(num or 1)
end
---@return number
function M.getlinenr()
    if M.incmd() then
        return 1
    end
    return vim.fn.line('.')--[[@as number]]
end
---@param pre? number
---@param pos? number
---@return string
function M.delete(pre,pos)
    return M.key_bs:rep(pre or 1)..M.key_del:rep(pos or 0)
end

---@param o core.o
---@return TSNode?
function M.gettsnode(o)
    --TODO: use vim.treesitter.get_string_parser for cmdline
    local cache=o.save
    local linenr,col=o.row+o._offset(o.row)-1,o.col+o._coloffset(o.col,o.row)-1
    if cache then
        if not cache[M.gettsnode] then cache[M.gettsnode]={} end
        cache=cache[M.gettsnode]
        if cache.no_parser then return end
        if cache[tostring(linenr)..';'..tostring(col)] then
            return cache[tostring(linenr)..';'..tostring(col)] or nil
        end
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
    (cache or {})[tostring(linenr)..';'..tostring(col)]=ret
    return ret
end
---@param o core.o
---@param notree boolean?
---@return string
function M.getsmartft(o,notree) --TODO: fix for empty lines
    --TODO: use vim.treesitter.get_string_parser for cmdline
    local cache=o.save
    local linenr,col=o.row+o._offset(o.row)-1,o.col+o._coloffset(o.col,o.row)-1
    if notree then return vim.o.filetype end
    if cache then
        if not cache[M.getsmartft] then cache[M.getsmartft]={} end
        cache=cache[M.getsmartft]
        if cache.no_parser then return vim.o.filetype end
        if cache[tostring(linenr)..';'..tostring(col)] then
            return cache[tostring(linenr)..';'..tostring(col)] or vim.o.filetype
        end
    end
    local stat,parser=pcall(vim.treesitter.get_parser,0)
    if not stat then
        (cache or {}).no_parser=true
        return vim.o.filetype
    end
    local pos={linenr,col,linenr,col}
    local ret=parser:language_for_range(pos):lang()
    if ret=='markdown_inline' then ret='markdown' end
    (cache or {})[tostring(linenr)..';'..tostring(col)]=ret
    return ret
end
---@return string
function M.getcmdtype()
    return vim.fn.getcmdtype() --[[@as string]]
end
---@param fn core.filter-fn
---@param o core.o
---@param col any
---@param row any?
---@return boolean?
function M._filter_pos(fn,o,col,row)
    return fn(M._get_o_pos(o,col,row))
end
---@param o core.o
---@param col any?
---@param row any?
---@return core.o
function M._get_o_pos(o,col,row)
    return {
        key=o.key,
        line=o.lines[row or o.row],
        lines=o.lines,
        col=col or o.col,
        row=row or o.row,
        _offset=o._offset,
        _coloffset=o._coloffset,
        incmd=o.incmd,
        save=o.save,
    }
end
return M
