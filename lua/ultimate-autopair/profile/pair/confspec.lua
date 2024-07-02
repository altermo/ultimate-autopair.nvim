local M={}
--DEFAULT VALUES SHOULD ONLY BE USED ONCE (once implemented into the specification), OTHERWISE ASSERT AN ERROR
--TODO: set the appropriate __runtime options
M.conf_spec={
    main={
        __inherit_keys={'maps'},
        __array_value='pair',
        map_modes='modes',
        pair_map_modes='modes',
        multiline='boolean',
        p='number',
        filter='filters',
        extension='TODO',
        integration='TODO',
        change={__array_value='pair'},
    },
    pair={
        __inherit_keys={'basepair'},
        --TODO: specify that some values need to be set, while others are optional
        [1]='string',
        [2]='string',
        map_modes='modes',
        start_pair='basepair',
        end_pair='basepair',
    },
    basepair={ --OOP lets gooo
        __inherit_keys={'maps','filters_nofn'},
        --TODO: specify that some values need to be set, while others are optional
        modes='modes',
        ft='array_of_strings',
        nft='array_of_strings',
        multiline='boolean',
        p='number',
        filter='filters',
        extension='TODO',
        start_pair_filter='filters', --TODO: temp
        end_pair_filter='filters', --TODO: temp
    },
    maps={
        backspace='backspace',
        newline='newline',
        space='space',
        fastwarp='fastwarp',
    },
    filters_nofn={
        alpha='alpha',
        cmdtype='cmdtype',
        escape='escape',
        filetype='filetype',
        tsnode='tsnode',
    },
    filters={
        __array_value='func',
        __inherit_keys={'filters_nofn'},
    },
    alpha={
        __inherit_keys={'basefilter'},
        before='boolean',
        after='boolean',
        py_fstr='boolean',
        lua_nstr='boolean',
        filter='boolean', --TODO: temp: this option should be replaced by something else
    },
    cmdtype={
        __inherit_keys={'basefilter'},
        skip={__not_table=true,__array_value={__type='enum',__data={'',':','>','/','?','@','-','='}}},
    },
    escape={
        __inherit_keys={'basefilter'},
        escapechar='string'
    },
    filetype={
        __inherit_keys={'basefilter'},
        ft='TODO', --TODO: array_of_filetypes instead of array_of_strings (filetype is for all intensive purposes a string (but extra validation))
        nft='TODO',
        detect_after='TODO',
        lang_detect_after='TODO',
        tree='boolean',
    },
    filter={
        filter='TODO',
        __inherit_keys={'basefilter'},
    },
    tsnode={
        __inherit_keys={'basefilter'},
        p='number',
        lang_detect_after='TODO',
        detect_after='TODO',
        node_detect_after='TODO',
        separate='array_of_strings',
        --TODO: tsnodes should be it's own type where the number keys point to the node types and any string keys are filetypes pointing to a list of node types
        --TODO: validate that each filetype has a corresponding treesitter language
        --TODO: validate each node type
    },
    basefilter={
        --modes='modes',
        p='number',
    },
    backspace={
        __inherit_keys={'basemap'},
        overjump={__inherit_keys='boolean',__runtime=true},
    },
    space={
        __inherit_keys={'basemap'},
    },
    newline={
        __inherit_keys={'basemap'},
    },
    fastwarp={
        __inherit_keys={'basemap'},
        nocursormove='boolean',
        rmap='map',
    },
    basemap={
        modes='modes',
        p='number',
        enable='boolean',
        map='map',
    },
    map={
        __type='special',
    },
    mode={
        __type='enum',
        __data={'n','v','x','s','o','!','i','l','c','t',''},
    },
    modes={
        __not_table=true,
        --TODO: modes (and other similars configs) should not be treated as table but as values
        --So instead of merge({'n'},{'v'}) becoming {'n','v'}, it becomes {'v'}
        --Similar to how merge('n','v') doesn't become 'nv', but 'v'
        __array_value='mode',
    },
    boolean={ --Should be inlined
        __type='type',
        __data='boolean',
    },
    string={ --Should be inlined
        __type='type',
        __data='string',
    },
    number={ --Should be inlined
        __type='type',
        __data='number',
    },
    func={ --Should be inlined
        __type='type',
        __data='function', --TODO: somehow encode more info into functions (like how many arguments it has (only on warnerr config check mode))
    },
    array_of_strings={ --Should be inlined
        __array_value='string',
    },
    TODO={
        __type='special',
    }
}
M.conf_spec_cache=vim.defaulttable(function (spec_name)
    if not M.conf_spec[spec_name].__inherit_keys then
        return M.conf_spec[spec_name]
    end
    local spec=vim.tbl_extend('error',{},M.conf_spec[spec_name])
    for _,ispec in ipairs(M.conf_spec[spec_name].__inherit_keys) do
        for k,v in pairs(M.conf_spec_cache[ispec]) do
            spec[k]=spec[k] or v
        end
    end
    return spec
end)
function M.error(type_,traceback,value,expected)
    if type_=='type' then
        error(('\n\n\n'..[[
        Configuration for the plugin 'ultimate-autopair' is incorrect.
        The option `%s` has the value `%s`, which has the type `%s`.
        However, that option should have the type `%s`.
        ]]..'\n'):format(traceback,vim.inspect(value),type(value),expected))
    elseif type_=='enum' then
        error(('\n\n\n'..[[
        Configuration for the plugin 'ultimate-autopair' is incorrect.
        The option `%s` contains the value `%s`.
        However, that option should be one of `%s`.
        ]]..'\n'):format(traceback,vim.inspect(value),expected))
    elseif type_=='table' then
        error(('\n\n\n'..[[
        Configuration for the plugin 'ultimate-autopair' is incorrect.
        The option `%s` has the value `%s`, which has the type `%s`.
        However, the option should be a table.
        ]]..'\n'):format(traceback,vim.inspect(value),type(value)))
    elseif type_=='key' then
            error(('\n\n\n'..[[
        Configuration for the plugin 'ultimate-autopair' is incorrect.
        The option `%s` is set (to `%s`), but it should not be set.
        ]]..'\n'):format(traceback,vim.inspect(value)))
    end
end
function M.validate(conf,spec_name,traceback)
    local spec=type(spec_name)=='table' and spec_name or M.conf_spec_cache[spec_name]
    if spec.__runtime==true and type(conf)=='function' then
        return
    elseif spec.__type=='type' then
        if type(conf)==spec.__data then
            return
        end
        M.error('type',traceback or ':root:',conf,spec.__data)
    elseif spec.__type=='enum' then
        for _,v in ipairs(spec.__data --[[@as table]]) do
            if v==conf then
                return
            end
        end
        M.error('enum',traceback or ':root:',conf,vim.inspect(spec.__data))
    elseif spec.__type=='special' then
        return
    elseif spec.__type and _G.UA_DEV then
        error''
    end
    if type(conf)~='table' then
        M.error('table',traceback or ':root:',conf,'table')
    end
    local tspec=setmetatable({merge='boolean'},{__index=spec})
    if tspec.__array_value then
        for k,_ in ipairs(conf) do
            ---@diagnostic disable-next-line: assign-type-mismatch
            tspec[k]=tspec.__array_value
        end
    end
    local function convert(t)
        if type(t)=='number' then
            return ('[%s]'):format(t)
        end
        return t
    end
    for k,v in pairs(conf) do
        local t=traceback and traceback..'.'..convert(k) or convert(k)
        if not tspec[k] then
            M.error('key',t,v,nil)
        end
        M.validate(v,tspec[k],t)
    end
end
function M.generate_random(spec_name)
    local out={}
    local spec=type(spec_name)=='table' and spec_name or M.conf_spec_cache[spec_name]
    if spec.__type=='type' then
        if spec.__data=='string' then
            local str=''
            for _=1,math.random(1,5) do
                str=str..string.char(math.random(33,126))
            end
            return str
        elseif spec.__data=='number' then
            return math.random(1,20)
        elseif spec.__data=='boolean' then
            return math.random(0,1)==0
        elseif spec.__data=='function' then
            return function () end
        else
            error''
        end
    elseif spec.__type=='enum' then
        return spec.__data[math.random(#spec.__data)]
    elseif spec.__type=='special' then
        return 'S'
    elseif spec.__type and _G.UA_DEV then
        error''
    end
    local tspec=vim.tbl_extend('error',{merge='boolean'},spec)
    if tspec.__array_value then
        for k=1,math.random(1,5) do
            tspec[k]=tspec.__array_value
        end
    end
    for k,v in pairs(tspec) do
        if type(k)=='number' or not k:find'^__' then
            out[k]=M.generate_random(v)
        end
    end
    return out
end
function M.merge(origin,new,merge,spec_name)
    local out={}
    local spec=type(spec_name)=='table' and spec_name or M.conf_spec_cache[spec_name]
    if spec.__type=='type' or spec.__type=='enum' or spec.__type=='special' or spec.__not_table then
        if new~=nil or merge==false then return new end
        return origin
    end
    if new and new.merge==false then merge=false
    elseif new and new.merge==true then merge=true
    end
    if origin==nil or merge==false then return new end
    if new==nil then return origin end
    local tspec=setmetatable({merge='boolean'},{__index=spec})
    for k,v in pairs(spec) do
        if type(k)=='number' or not k:find'^__' and (origin[k]~=nil or new[k]~=nil) then
            if (not M.__array_value) or type(v)~='number' then
                out[k]=M.merge(origin[k],new[k],merge,v)
            end
        end
    end
    if tspec.__array_value then
        local has={}
        for k,v in pairs(origin) do
            if type(k)=='number' then
                has[v]=true
                table.insert(out,v)
            end
        end
        for k,v in pairs(new) do
            if type(k)=='number' then
                if not has[v] then table.insert(out,v) end
            end
        end
    end
    return out
end
function M.inherit(config) --TODO: temp
    local out=setmetatable({},{__index=config})
    if not config.pair_map_modes then
        out.pair_map_modes=config.map_modes
    end
    for _,v in pairs(require'ultimate-autopair.profile.pair.map'.maps) do
        out[v]=setmetatable({modes=M.merge(config.map_modes,config[v].modes,true,'modes')},{__index=config[v]})
    end
    local somepairs=vim.defaulttable(function() return {} end)
    for k,v in ipairs(config) do
        table.insert(somepairs[v[1]:gsub(';',';;')..';-'..v[2]],k)
    end
    local change={}
    for _,v in ipairs(config.change or {}) do
        assert(somepairs[v[1]:gsub(';',';;')..';-'..v[2]],('ultimate-autopair: configuration: trying to change pair %s,%s which does not exist'):format(v[1],v[2]))
        for _,key in ipairs(somepairs[v[1]:gsub(';',';;')..';-'..v[2]]) do
            change[key]=v
        end
    end
    for k,pair in pairs(config) do
        if type(k)~='number' then goto continue end
        out[k]=setmetatable({
            map_modes=M.merge(out.pair_map_modes,pair.map_modes,true,'modes'),
            multiline=M.merge(config.multiline,pair.multiline,true,'boolean'),
        },{__index=pair})
        if change[k] then
            out[k]=M.merge(out[k],change[k],true,'pair')
        end
        local filters={}
        for filter,_ in pairs(config.filter or {}) do
            if type(filter)~='number' then --TODO: temp
                filters[filter]=out[k][filter]
            end
        end
        filters=M.merge(filters,config.filter,true,'filters')
        filters=M.merge(pair.filter,filters,true,'filters')
        if pair.ft and filters.filetype then
            filters.filetype=setmetatable({ft=M.merge(filters.filetype.ft,pair.ft,true,'array_of_strings')},{__index=filters.filetype})
        end
        if pair.nft and filters.filetype then
            filters.filetype=setmetatable({nft=M.merge(filters.filetype.nft,pair.nft,true,'array_of_strings')},{__index=filters.filetype})
        end
        out[k].start_pair_filter=M.merge(filters,pair.start_pair,true,'filters')
        out[k].end_pair_filter=M.merge(filters,pair.end_pair,true,'filters')
        out[k].extension=config.extension
        ::continue::
    end
    return out
end
return M
