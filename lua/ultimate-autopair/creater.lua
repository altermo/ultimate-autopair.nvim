local mem=require'ultimate-autopair.memory'
local utils=require'ultimate-autopair.utils.utils'
local M={}
function M.create_function(key,filters)
    return function()
        local H={}
        H.key=key
        for _,v in ipairs(filters) do
            local exit_status=v.call(H,v.conf,mem.mem[H.key] and mem.mem[H.key].ext[v.name] or {},mem.mem)
            if exit_status then
                if exit_status==2 then
                    utils.append(key)
                end
                return
            end
        end
        utils.append(key)
    end
end
function M.create_map(pair,paire,opt,typ)
    local config=require('ultimate-autopair.config')
    local key=(typ==2 and paire or pair)
    mem.addpair(key,pair,paire,typ)
    for name,extension in pairs(mem.extensions)do
        if extension.init then
            mem.addext(key,name)
            extension.init(opt,mem.mem[key].ext[name],extension.conf,mem.mem)
        end
    end
    local char=key:sub(-1,-1)
    if not mem.mapped[char] then
        vim.keymap.set('i',char,M.create_function(char,mem.filters),config.conf.mapopt)
        vim.keymap.set('c',char,M.create_function(char,mem.filters),config.conf.mapopt)
        mem.mapped[char]=true
    end
end
return M
