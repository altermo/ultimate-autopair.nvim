local confgen=require'ultimate-autopair.conf'

---TODO: just test that it works, please just test it (as it seems like it's not well designed)

---TODO: have more default_configs, like `old` config, which will make things work as much like version v0.6 as possible (require some rework of cache (or just enum...))

local M={conf={}}
---@type ua.config
M.conf.default={
    fallback={
        [true]=true,
    },
    map_mode={'i','c'},
    multiline=true,
    use_filetype_getopt=false,
    treesitter_async=false,
    {'(',')'},
    {'[',']'},
    {'{','}'},
    {'"','"',multiline=false,filter={filetype={nft={'tex'}}}},
    {{"'",filter={alpha={before=true,singlechar=true}}},"'",
        multiline=false,filter={filetype={nft={'tex','rust'}}},
        --[[filter_on_insert=in_lisp TODO]]},
    root_filter={
        cmdtype={skip={'/','?','@'}},
        escape={},
        -- alpha={},
        filetype={nft={'TelescopePrompt'}},
        tsnode={nodeclass_filter={string='separate',comment='separate'}},
    },
    backspace={
        map='<bs>',
        overjump='nonambiguous',
    },
    newline={
        map='<cr>',
    },
    space={
        enable=false,
        map='<space>',
    },
    -- TODO
    -- fastwarp={
    --     enable=false,
    --     type='normal',
    --     map='<A-e>',
    --     r_map='<A-E>',
    -- },
}

---@generic T
---@param conf T?
---@param default T|any
---@return T
local function merge(conf,default)
    if conf==nil then
        return default
    elseif type(conf)~='table' then
        return conf
    elseif type(default)~='table' then
        return conf
    end
    local out={}
    for k,v in pairs(default) do
        out[k]=v
    end
    for k,v in pairs(conf) do
        out[k]=v
    end
    return out
end

---@param conf ua.config
---@param dont_default table<string|number,true>?
---@param key_change table<number,table>?
---@return ua.config
local function root_merge(conf,key_change,dont_default)
    local out_conf={}
    for k,v in pairs(conf) do
        if type(k)=='number' then
            out_conf[k]=v
        elseif dont_default and dont_default[k] then
            out_conf[k]=v
        elseif M.conf.default[k]==nil then
            out_conf[k]=v
        elseif k=='root_filter' then
            out_conf.root_filter={}
            for k2,v2 in pairs(v) do
                if dont_default and dont_default['filter.'..k2] then
                    out_conf.root_filter[k2]=v2
                elseif M.conf.default.root_filter[k2]==nil then
                    out_conf.root_filter[k2]=v2
                else
                    out_conf.root_filter[k2]=merge(v2,M.conf.default.root_filter[k2])
                end
            end
        else
            out_conf[k]=merge(v,M.conf.default[k])
        end
    end
    for k,v in pairs(M.conf.default) do
        if dont_default and dont_default[k] then
        elseif type(k)=='number' then
            if key_change and key_change[k] then
                table.insert(out_conf,vim.tbl_deep_extend('force',v,key_change[k]))
            else
                table.insert(out_conf,v)
            end
        elseif out_conf[k]~=nil then
        elseif k=='root_filter' then
            out_conf.root_filter={}
            for k2,v2 in pairs(v) do
                if dont_default and dont_default['filter.'..k2] then
                else
                    out_conf.root_filter[k2]=v2
                end
            end
        else
            out_conf[k]=v
        end
    end
    return out_conf
end

---@param conf ua.config
---@return ua.config
function M.merge_with_default(conf)
    --TODO: what happens to whether `filter.filetype` is default if `exclude=true` and `filter` is in the list?
    --TODO: what happens to whether `()` pair is default if `exclude=true` and `pair` is in the list?

    -- TODO: doesn't the function return the opisit to what we want
    local dont_default,key_change=confgen._generate_opt_default_validate(conf,M.conf.default)
    if dont_default==false then
        return conf
    end

    if next(conf)==nil then
        return M.conf.default
    end

    return root_merge(conf,key_change,dont_default~=true and dont_default or nil)
end
return M
