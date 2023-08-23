--Internal
local M={}
M.I={}
function M.I.create_scratch_buf(win,name)
    local buf=vim.api.nvim_create_buf(false,true)
    vim.api.nvim_set_option_value('bufhidden','wipe',{buf=buf})
    if win then vim.api.nvim_win_set_buf(win,buf) end
    if name then vim.api.nvim_buf_set_name(buf,name) end
    return buf
end
function M.create_traceback_buf(traceback,win,mes)
    local buf=M.I.create_scratch_buf(win,'traceback')
    local places={}
    local function nw(text) return function () vim.notify(text) end end
    local function file_open_wrapp(file,row)
        return function ()
            vim.cmd.vnew(file)
            if row then vim.cmd(tostring(row)) end
        end
    end
    vim.api.nvim_buf_set_lines(buf,0,-1,false,{'Press <CR> on line to open file'})
    table.insert(places,nw("Can't enter an instruction"))
    vim.api.nvim_buf_set_lines(buf,1,1,false,{'The error is: '..mes})
    table.insert(places,nw("Can't enter an error message"))
    vim.api.nvim_buf_set_lines(buf,2,2,false,{''})
    table.insert(places,nw("Can't enter a blank line"))
    for _,v in ipairs(traceback) do
        local line
        local enter
        local file=v.source:gsub('^@','')
        if v.what=='C' then
            line='C:'..v.name
            enter=nw("Can't enter lua-c code")
        elseif v.what=='main' then
            line='file:'..file
            enter=file_open_wrapp(file)
        elseif vim.startswith(v.source,'@vim/') then
            line='vim:'..v.name..':'..file
            enter=function ()
                vim.cmd.help('vim.'..v.name)
            end
        else
            line='in:'..v.currentline..':'..file
            enter=file_open_wrapp(file,v.currentline)
        end
        table.insert(places,enter)
        vim.api.nvim_buf_set_lines(buf,-1,-1,false,{line})
    end
    vim.api.nvim_set_option_value('modifiable',false,{buf=buf})
    vim.keymap.set('n','<cr>',function() places[vim.fn.line('.')]() end,{buffer=buf})
end
function M.get_traceback_data(level)
    local ret={}
    while true do
        local info=debug.getinfo(level,'nSlufL')
        if not info then break end
        table.insert(ret,info)
        level=level+1
    end
    return ret
end
function M.create_info_buf(info,win)
    local buf=M.I.create_scratch_buf(win,'info')
    vim.api.nvim_buf_set_lines(buf,0,0,false,vim.split(vim.inspect(info),'\n'))
    vim.api.nvim_set_option_value('modifiable',false,{buf=buf})
end
function M.create_debug_bufs(opts,traceback,mes)
    vim.cmd.vsplit()
    M.create_info_buf(opts,vim.api.nvim_get_current_win())
    vim.cmd.split()
    M.create_traceback_buf(traceback,vim.api.nvim_get_current_win(),mes)
end
function M.handeler_wrapp(opts)
    return function (mes)
        if mes==nil then mes='nil' end
        local traceback=M.get_traceback_data(3)
        local tracebackmes=debug.traceback(mes)
        vim.schedule(function ()
            vim.api.nvim_echo({{tracebackmes,'error'},{'\n(Ingore the line bellow) press y to start debugger (or c to copy traceback):'}},false,{})
            local inp=vim.fn.getcharstr() or ''
            if inp=='c' then
                vim.fn.setreg('+',tracebackmes)
            end
            if inp~='y' then return end
            vim.cmd.stopinsert()
            opts.mes=mes
            M.create_debug_bufs(opts,traceback,mes)
        end)
    end
end
---@param fn function
---@param opts table
---@return any
function M.run(fn,opts)
    ---@diagnostic disable-next-line: undefined-field
    if _G.UA_DEBUG_DONT then return fn(unpack(opts.args or {})) end
    local s={xpcall(fn,M.handeler_wrapp(opts),unpack(opts.args or {}))}
    if not s[1] then return end
    return unpack(s,2)
end
---@param fn function
---@param opts table
---@return function
function M.wrapp_run(fn,opts)
    return function (...)
        opts.args={...}
        return M.run(fn,opts)
    end
end
return M
