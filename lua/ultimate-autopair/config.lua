local M={}
local creater=require'ultimate-autopair.creater'
local mem=require'ultimate-autopair.memory'
local defaults=require'ultimate-autopair.defaults'
M.conf=defaults.default_config
function M.create_map_pair(opt)
    if opt[1]==opt[2] then
        creater.create_map(opt[1],opt[2],opt,3,M.conf.cmap)
    else
        creater.create_map(opt[1],opt[2],opt,1,M.conf.cmap)
        creater.create_map(opt[1],opt[2],opt,2,M.conf.cmap)
    end
end
function M.setup_extensions()
    if not M.conf.extensions then return end
    for _,v in ipairs(M.conf.extensions) do
        if type(v)=="table" then
            mem.extensions[v[1]]=vim.tbl_extend('error',mem.load_extension(v[1]),{conf=v[2]})
            mem.oextensions[#mem.oextensions+1]=v[1]
        elseif type(v)=='string' then
            mem.extensions[v]=mem.load_extension(v)
            mem.oextensions[#mem.oextensions+1]=v
        else
            mem.extensions[#mem.extensions+1]={filter=v}
            mem.oextensions[#mem.oextensions+1]=#mem.extensions
        end
    end
end
function M.setup(config)
    if config._repconf then
        M.conf=config
    else
        M.conf=vim.tbl_deep_extend('force',defaults.default_config,config)
    end
end
function M.create_mappings()
    if not M.conf then return end
    for _,v in ipairs(M.conf) do
        if not v.disable then
            M.create_map_pair(v)
        end
    end
    for _,i in pairs(mem.oextensions) do
        if type(i)=='string' then
            ---@diagnostic disable-next-line: param-type-mismatch
            for _,v in ipairs(M.conf[i] or {}) do
                if not v.disable then
                    M.create_map_pair(v)
                end
            end
        end
    end
    if mem.extensions.filetype then
        for ft,i in pairs(M.conf.ft or {}) do
            for _,v in ipairs(i) do
                if not v.disable then
                    M.create_map_pair(vim.tbl_extend('force',v,{ft=ft}))
                end
            end
        end
    end
    for _,i in ipairs(M.conf.special or {}) do
        mem.addpair(i.id,i.pair,i.paire,i.type)
        mem.init_map(i.id,i.opt)
        if i.key then
            creater.create_vim_keymap(i.key,i.cmdmode)
        end
    end
end
return M
