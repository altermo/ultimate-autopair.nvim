--Internal
local M={}
local utils=require'ultimate-autopair.utils'
local debug=require'ultimate-autopair.debug'
M.mem={}
M.mapc={}
M.mapi={}
M.funcs={}
M.I={}
function M.I.get_maps(mode)
    local maps=vim.api.nvim_get_keymap(mode)
    local ret={}
    for _,v in ipairs(maps) do
        ret[v.lhs]=v
    end
    return ret
end
function M.I.activate_iabbrev(key)
    if key:sub(1,1)=='\r' then
        return '\x1d'..key
    elseif vim.regex('[^[:keyword:][:cntrl:]\x80]'):match_str(key:sub(1,1)) then
        return '\x1d'..key
    end
    return key
end
function M.I.var_create_wrapper(key)
    local line=utils.getline()
    local col=utils.getcol()
    local linenr=utils.getlinenr()
    local incmd=utils.incmd()
    return function ()
        return {
            key=key,
            line=line,
            col=col,
            linenr=linenr,
            incmd=incmd
        }
    end
end
function M.get_run(key)
    if not M.funcs[key] then
        M.funcs[key]=M.run_wrapp(key)
    end
    return M.funcs[key]
end
function M.run(key)
    if M.disable then
        return M.I.activate_iabbrev(vim.api.nvim_replace_termcodes(key,true,true,true))
    end
    local fo=M.I.var_create_wrapper(key)
    for _,v in ipairs(M.mem) do
        local ret
        if v.check then
            ret=debug.wrapp_smart_debugger(v.check,v)(fo())
        end
        if ret then
            return M.I.activate_iabbrev(ret)
        end
    end
    return M.I.activate_iabbrev(vim.api.nvim_replace_termcodes(key,true,true,true))
end
function M.run_wrapp(key)
    return function ()
        return M.run(key)
    end
end
function M.clear()
    for _,v in ipairs(M.mem) do
        if v.oinit then v.oinit(true) end
    end
    local imapps=M.I.get_maps('i')
    local cmapps=M.I.get_maps('c')
    for k,v in pairs(M.mapc) do
        if cmapps[k] and M.funcs[k] and cmapps[k].callback==M.funcs[k] then
            vim.keymap.del('c',k,{})
            if v then vim.fn.mapset('c',false,v) end
        end
    end
    for k,v in pairs(M.mapi) do
        if imapps[k] and M.funcs[k] and imapps[k].callback==M.funcs[k] then
            vim.keymap.del('i',k,{})
            if v then vim.fn.mapset('i',false,v) end
        end
    end
    M.mem={}
    M.mapc={}
    M.mapi={}
    M.funcs={}
end
function M.I.sort()
    table.sort(M.mem,function(a,b)
        if a.p~=b.p then
            return a.p>b.p
        end
        if a.sort then
            local bool=a.sort(a,b)
            if bool~=nil then return bool end
        end
        if b.sort then
            local bool=b.sort(a,b)
            if bool~=nil then return bool end
        end
        return false
    end)
end
function M.init()
    M.I.sort()
    local imapped=vim.defaulttable()
    local cmapped=vim.defaulttable()
    for _,v in ipairs(M.mem) do
        if v.oinit then v.oinit() end
        if v.get_map then
            for _,key in ipairs(v.get_map('i') or {}) do
                table.insert(imapped[key].desc,v.doc)
            end
            for _,key in ipairs(v.get_map('c') or {}) do
                table.insert(cmapped[key].desc,v.doc)
            end
        end
    end
    local imapps=M.I.get_maps('i')
    local cmapps=M.I.get_maps('c')
    for k,v in pairs(imapped) do
        M.mapi[k]=imapps[k] or false
        vim.keymap.set('i',k,M.get_run(k),{noremap=true,expr=true,desc=vim.fn.join(v.desc,'\n\t\t '),replace_keycodes=false})
    end
    for k,v in pairs(cmapped) do
        M.mapc[k]=cmapps[k] or false
        vim.keymap.set('c',k,M.get_run(k),{noremap=true,expr=true,desc=vim.fn.join(v.desc,'\n\t\t '),replace_keycodes=false})
    end
end
return M
