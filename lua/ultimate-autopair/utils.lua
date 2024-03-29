--Internal Utils
local M={}
M.maxlines=500
---@param linenr? number
---@return string
function M.getline(linenr)
    if M.incmd() then
        return vim.fn.getcmdline()--[[@as string]]
    end
    linenr=linenr or M.getlinenr()
    return unpack(M._getlines(linenr-1,linenr))
end
---@param start number
---@param end_ number
---@return string[]
function M._getlines(start,end_)
    return vim.api.nvim_buf_get_lines(0,start,end_,true)
end
---@return integer
---@return string[]
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
    ---@diagnostic disable-next-line: redundant-parameter
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
function M._movel(num)
    if M.incmd() then
        return M.key_right:rep(num or 1)
    end
    return (M.key_noundo..M.key_right):rep(num or 1)
end
---@param num? number
---@return string
function M._moveh(num)
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
function M._delete(pre,pos)
    return M.key_bs:rep(pre or 1)..M.key_del:rep(pos or 0)
end
---@param actions core.act
---@return string
function M.create_act(actions)
    local ret=''
    for _,v in ipairs(actions) do
        local c=v[1]
        local a1,a2
        if type(v)~='string' then a1,a2=unpack(v,2) end
        if c=='move' then
            if a1<0 then c='h' a1=-a1
            else c='l' end
        end
        if type(v)=='string' then ret=ret..v
        elseif c=='newline' then ret=ret..'\n'
        elseif c=='home' then ret=ret..M.key_home
        elseif c=='end' then ret=ret..M.key_end
        elseif c=='j' then ret=ret..M.key_down:rep(a1 or 1)
        elseif c=='k' then ret=ret..M.key_up:rep(a1 or 1)
        elseif c=='h' then ret=ret..M._moveh(a1)
        elseif c=='l' then ret=ret..M._movel(a1)
        elseif c=='delete' then ret=ret..M._delete(a1,a2)
        elseif c=='sub' then ret=ret..M.create_act(a1)
        end
    end
    return ret
end
---@param node TSNode
---@param o core.o
---@return number?
---@return number?
---@return number?
---@return number?
function M.gettsnodepos(node,o)
    local srow,scol,erow,ecol=node:range()
    return srow+1+o._deoffset(srow+1),scol+1+o._decoloffset(scol+1,srow+1),erow+1+o._deoffset(erow+1),ecol+o._decoloffset(ecol,erow+1)
end
---@param o core.o
---@param extend? number
---@param extendpre? number
---@return TSNode?
function M.gettsnode(o,extend,extendpre)
    --TODO: use vim.treesitter.get_string_parser for cmdline
    if o.incmd then return end
    local save=o.save[M.gettsnode] or {} o.save[M.gettsnode]=save
    if save.no_parser then return end
    local linenr,col=o.row+o._offset(o.row)-1,o.col+o._coloffset(o.col,o.row)-1
    if save[tostring(linenr)..';'..tostring(col)]~=nil then
        return save[tostring(linenr)..';'..tostring(col)] or nil
    end
    local s,parser=pcall(vim.treesitter.get_parser)
    if not s then save.no_parser=true return end
    if not save.has_parsed then
        parser:parse(true)
        save.has_parsed=true
    end
    local getnode
    if extend then
        getnode=function (linenr_,col_)
            return parser:named_node_for_range({linenr_,col_-(extendpre or 0),linenr_,col_+extend},{ignore_injections=false})
        end
    elseif vim.treesitter.get_node then
        getnode=function (linenr_,col_)
            return vim.treesitter.get_node({bufnr=0,pos={linenr_,col_},ignore_injections=false})
        end
    else
        getnode=function (linenr_,col_)
            ---@diagnostic disable-next-line: deprecated
            return vim.treesitter.get_node_at_pos(0,linenr_,col_,{ignore_injections=false})
        end
    end
    local ret=getnode(linenr,col)
    if ret and col==#unpack(M._getlines(linenr,linenr+1)) and col~=0 then
        local node=getnode(linenr,col-1)
        if  node then
            local _,end_=node:end_()
            if o.col==end_+1 then ret=node end
        end
    end
    save[tostring(linenr)..';'..tostring(col)]=ret or false
    if not ret then return nil end
    return ret
end
---@param o core.o
---@param notree boolean?
---@return string
function M.getsmartft(o,notree)
    --TODO: fix for empty lines
    --TODO: use vim.treesitter.get_string_parser for cmdline
    if o.incmd then return 'vim' end
    if notree then return vim.o.filetype end
    local cache=o.save
    if not cache[M.getsmartft] then cache[M.getsmartft]={} end
    cache=cache[M.getsmartft]
    if cache.no_parser then return vim.o.filetype end
    local linenr,col=o.row+o._offset(o.row)-1,o.col+o._coloffset(o.col,o.row)-1
    if cache[tostring(linenr)..';'..tostring(col)] then
        return cache[tostring(linenr)..';'..tostring(col)] or vim.o.filetype
    end
    local s,parser=pcall(vim.treesitter.get_parser)
    if not s then cache.no_parser=true return vim.o.filetype end
    if not cache.has_parsed then
        parser:parse(true)
        cache.has_parsed=true
    end
    local pos={linenr,col,linenr,col}
    local tslang2lang=setmetatable({
        markdown_inline='markdown',
        bash='sh',
        javascript='javascript',
        markdown='markdown',
        html='html',
        xml='xml',
        scala='scala',
        latex='tex',
        ini='ini',
        glimmer='handlebars',
        verilog='verilog',
        tsx='typescriptreact',
    },{__index=function (_,index)
            return vim.treesitter.language.get_filetypes(index)[1]
        end})
    local ret=tslang2lang[parser:language_for_range(pos):lang()]
    if cache then cache[tostring(linenr)..';'..tostring(col)]=ret end
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
        _deoffset=o._deoffset,
        _coloffset=o._coloffset,
        _decoloffset=o._decoloffset,
        incmd=o.incmd,
        save=o.save,
        mode=o.mode,
    }
end
---@param filetype string
---@param option string
function M.ft_get_option(filetype,option)
    local err,ret=pcall(vim.filetype.get_option,filetype,option)
    if not err then
        return vim.api.nvim_get_option_value(option,{buf=vim.api.nvim_get_current_buf()})
    end
    return ret
end
---@generic T:string|string?
---@param str T
---@return T
function M.keycode(str)
    return str and vim.api.nvim_replace_termcodes(str,true,true,true)
end
M.key_bs=M.keycode'<bs>'
M.key_del=M.keycode'<del>'
M.key_left=M.keycode'<left>'
M.key_right=M.keycode'<right>'
M.key_end=M.keycode'<end>'
M.key_home=M.keycode'<home>'
M.key_up=M.keycode'<up>'
M.key_down=M.keycode'<down>'
M.key_noundo=M.keycode'<C-g>U'

M.interop={}
---@return string
function M.interop.get_endwise()
    if not M.interop.endwise then
        if not M.interop.try_load_endwise() then return '' end
    end
    local _,_,end_text=M.interop.endwise()
    return end_text or ''
end
function M.interop.try_load_endwise()
    if M.interop.endwise then return true end
    if not pcall(require,'nvim-treesitter-endwise') then return end
    local _,fns=debug.getupvalue(vim.on_key,1)
    local endwise,tracking
    for _,fn in pairs(fns) do
        if vim.endswith(debug.getinfo(fn).source,'/endwise.lua') then
            local name
            name,tracking=debug.getupvalue(fn,1)
            if name~='tracking' then tracking=nil  end
            name,endwise=debug.getupvalue(fn,2)
            if name~='endwise' then endwise=nil end
        end
    end
    if not endwise or not tracking then return end
    local name,add_end_node=debug.getupvalue(endwise,7)
    if name~='add_end_node' then return end
    M.interop.endwise=function ()
        local buf=vim.api.nvim_get_current_buf()
        if not tracking[buf] then return end
        local ret
        debug.setupvalue(endwise,7,function (...) ret=vim.F.pack_len(...) end)
        local s,mes=pcall(endwise,buf)
        debug.setupvalue(endwise,7,add_end_node)
        if not s then error(mes) end
        if not ret then return end
        return vim.F.unpack_len(ret)
    end
    return true
end
return M
