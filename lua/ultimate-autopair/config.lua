local M={}
local creater=require'ultimate-autopair.creater'
local mem=require'ultimate-autopair.memory'
local defaults=require'ultimate-autopair.utils.defaults'
M.conf=defaults.default_config
function M.create_map_pair(opt)
    if opt[1]==opt[2] then
        creater.create_map(opt[1],opt[2],opt,3)
    else
        creater.create_map(opt[1],opt[2],opt,1)
        creater.create_map(opt[1],opt[2],opt,2)
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
    if not mem.extensions.filetype then return end
    if not M.conf.ft then return end
    for ft,i in pairs(M.conf.ft) do
        for _,v in ipairs(i) do
            if not v.disable then
                M.create_map_pair(vim.tbl_extend('force',v,{ft=ft}))
            end
        end
    end
end
return M
