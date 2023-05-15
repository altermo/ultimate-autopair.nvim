--Internal
local M={}
local utils=require'ultimate-autopair.utils'
local debug_status,debug=pcall(require,'ultimate-autopair.debug')
M.mem={}
M.I={}
function M.I.activate_iabbrev(key)
    if key:sub(1,4)=='<cr>' then
        return '<C-]>'..key
    end
    local match=vim.api.nvim_replace_termcodes(key,true,true,true)
    if vim.regex('[^[:keyword:][:cntrl:]\x80]'):match_str(match:sub(1,1)) then
        return '<C-]>'..key
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
function M.run(key)
    return function ()
        local fo=M.I.var_create_wrapper(key)
        for _,v in ipairs(M.mem) do
            local ret
            if not v.check then
            elseif debug_status then
                ret=debug.create_check_debuger(v.check,v)(fo())
            else
                ret=v.check(fo())
            end
            if ret then
                return M.I.activate_iabbrev(ret)
            end
        end
        return M.I.activate_iabbrev(key)
    end
end
function M.clear()
    if not vim.tbl_isempty(M.mem or {}) then error('Double initialization of plugin ultimate-autopair') end
    M.mem={}
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
    for _,v in ipairs(M.mem) do
        if v.oinit then v.oinit() end
        if v.get_map then
            for _,key in ipairs(v.get_map('i') or {}) do
                vim.keymap.set('i',key,M.run(key),{noremap=true,expr=true})
            end
            for _,key in ipairs(v.get_map('c') or {}) do
                vim.keymap.set('c',key,M.run(key),{noremap=true,expr=true})
            end
        end
    end
end
return M