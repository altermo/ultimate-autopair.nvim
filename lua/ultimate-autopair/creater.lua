local mem=require'ultimate-autopair.memory'
local M={}
function M.create_function(key,filters)
    return function()
        local H={}
        H.key=key
        for _,filter in ipairs(filters) do
            local exit_key=filter.call(H,filter.conf,mem.mem[H.key] and mem.mem[H.key].ext[filter.name] or {},mem.mem)
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
function M.create_map(pair,paire,opt,typ,cmdmode)
    local config=require('ultimate-autopair.config')
    local key=(typ==2 and paire or pair)
    mem.addpair(key,pair,paire,typ)
    for name,extension in pairs(mem.extensions) do
        if extension.init then
            mem.addext(key,name)
            extension.init(opt,mem.mem[key].ext[name],extension.conf,mem.mem)
        end
    end
    local char=key:sub(-1,-1)
    if not mem.mapped[char] then
        local func=M.create_function(char,mem.filters)
        vim.keymap.set('i',char,func,vim.tbl_extend('error',config.conf.mapopt,{expr=true}))
        if cmdmode then
            vim.keymap.set('c',char,func,vim.tbl_extend('error',config.conf.mapopt,{expr=true}))
        end
        mem.mapped[char]=func
    end
end
return M
