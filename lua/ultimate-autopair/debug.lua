local M={}
M.I={}
function M.I.sbuf()
    local buf=vim.api.nvim_create_buf(false,true)
    vim.api.nvim_set_option_value('bufhidden','wipe',{buf=buf})
    return buf
end
function M.parse_error_line(line)
    local ret={}
    local pline=vim.trim(line)
    local p=vim.split(pline,':')
    ret.line=line
    ret.p=p
    ret.file=p[1]
    if ret.file=='[C]' then
        ret.func=vim.split(p[2],"'")[2]
        ret.type='c'
    elseif vim.startswith(ret.file,'vim/') then
        ret.func=vim.split(p[2],"'")[2]
        ret.type='vim'
    else
        ret.row=p[2]
        if vim.startswith(line,'\t') then
            if p[3]==' in main chunk' then
                ret.type='main'
            else
                ret.funcfile=vim.split(p[3],'<')[2]
                ret.funcrow=vim.split(p[4],'>')[1]
                ret.type='norm'
            end
        else
            ret.err=p[3]:sub(2)
            ret.type='err'
        end
    end
    return ret
end
function M.create_traceback_buf(traceback,win,mes)
    local buf=M.I.sbuf()
    vim.api.nvim_win_set_buf(win,buf)
    local places={}
    vim.api.nvim_buf_set_lines(buf,0,0,false,{'Press <CR> on line to vedit file'})
    table.insert(places,function (_) vim.notify('This is not a file') end)
    vim.api.nvim_buf_set_lines(buf,1,1,false,{'The error is: '..mes})
    table.insert(places,function (_) vim.notify('This is the error message, and not a file') end)
    vim.api.nvim_buf_set_name(buf,'traceback')
    table.insert(places,function (_) vim.notify('This is not a file') end)
    for _,v in ipairs(traceback) do
        local line
        local enter=function (_) vim.notify("can't enter this file") end
        local function file_open_wrapper(file,row)
            return function (cmd)
                cmd(file)
                if row then vim.cmd(tostring(row)) end
            end
        end
        local file=v.source:gsub('^@','')
        if v.what=='C' then
            line='C:'..v.name
        elseif v.what=='main' then
            line='file:'..file
            enter=file_open_wrapper(file)
        elseif vim.startswith(v.source,'@vim/') then
            line='vim:'..v.name..':'..file
        else
            line='in:'..v.currentline..':'..file
            enter=file_open_wrapper(file,v.currentline)
        end
        table.insert(places,enter)
        vim.api.nvim_buf_set_lines(buf,-1,-1,false,{line})
    end
    vim.api.nvim_set_option_value('modifiable',false,{buf=buf})
    vim.keymap.set('n','<cr>',function() places[vim.fn.line('.')](vim.cmd.vsplit) end,{buffer=buf})
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
function M.handel_err(o,traceback,mes)
    vim.cmd.vsplit()
    M.create_traceback_buf(traceback,vim.api.nvim_get_current_win(),mes)
    vim.cmd.split()
    M.create_debug_buf(o,vim.api.nvim_get_current_win())
end
function M.create_debug_buf(o,win)
    local buf=M.I.sbuf()
    vim.api.nvim_win_set_buf(win,buf)
    vim.api.nvim_buf_set_name(buf,'info')
    vim.api.nvim_buf_set_lines(buf,0,0,false,vim.split(vim.inspect(o),'\n'))
    vim.api.nvim_set_option_value('modifiable',false,{buf=buf})
end
function M.handel_smart_debug(o)
    return function (mes)
        if mes==nil then mes='nil' end
        local traceback=M.get_traceback_data(3)
        local inp=vim.fn.input(debug.traceback(mes)..'\nenter y/yes to start debugger (or c/copy to copy traceback):')
        if vim.tbl_contains({'c','copy','C','Copy'},string.lower(inp)) then
            vim.fn.setreg('+',mes..debug.traceback(mes))
        end
        if not vim.tbl_contains({'y','Y','yes','Yes'},inp) then return end
        vim.cmd.stopinsert()
        o.mes=mes
        vim.schedule_wrap(M.handel_err)(o,traceback,mes)
    end
end
function M.wrapp_smart_debugger(f,info)
    return M.create_debug(f,M.handel_smart_debug,info)
end
function M.create_debug(f,handeler_wrapper,info)
    ---@diagnostic disable-next-line: undefined-field
    if _G.DONTDEBUG then
        return function (...) return f(...) end
    end
    return function (...)
        local s={xpcall(f,handeler_wrapper({info=info,args={...}}),...)}
        if not s[1] then return end
        return unpack(s,2)
    end
end
return M
