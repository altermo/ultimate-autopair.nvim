local mem=require'ultimate-autopair.memory'
local M={}
function M.create_function(key,filters)
    return function()
        local H={}
        H.key=key
        for _,filter in ipairs(filters) do
            local exit_key=filter.call(H,filter.conf or {},mem.mem)
            if exit_key==2 then
                return '\x1d'..key
            elseif exit_key==1 then
                return ''
            elseif exit_key then
                return '\x1d'..exit_key
            end
        end
        return '\x1d'..key
    end
end
function M.create_vim_keymap(char,cmdmode)
    local config=require('ultimate-autopair.config')
    if not mem.mapped[char] then
        local func=M.create_function(char,mem.filters)
        vim.keymap.set('i',char,func,vim.tbl_extend('error',config.conf.mapopt,{expr=true}))
        if cmdmode then
            vim.keymap.set('c',char,func,vim.tbl_extend('error',config.conf.mapopt,{expr=true}))
        end
        mem.mapped[char]=func
    end
end
function M.create_map(pair,paire,opt,typ,cmdmode)
    local key=(typ==2 and paire or pair)
    mem.addpair(key,pair,paire,typ,opt)
    if typ~=1 then
        M.create_vim_keymap(key:sub(1,1),cmdmode)
    end
    if typ~=2 then
        M.create_vim_keymap(key:sub(-1,-1),cmdmode)
    end
end
return M
