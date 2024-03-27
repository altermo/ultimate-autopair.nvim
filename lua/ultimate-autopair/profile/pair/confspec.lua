local M={}
--DEFAULT VALUES SHOULD ONLY BE USED ONCE (once implemented into the specification), OTHERWISE ASSERT AN ERROR
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
    },
    pair={
        __inherit_keys={'basepair'},
        --TODO: specify that some values need to be set, while others are optional
        [1]='string',
        [2]='string',
        start_pair='basepair',
        end_pair='basepair',
    },
    basepair={ --OOP lets gooo
        __inherit_keys={'maps','filters'},
        --TODO: specify that some values need to be set, while others are optional
        modes='modes',
        ft='array_of_strings',
        nft='array_of_strings',
        multiline='boolean',
        p='number',
        insert='filter',
    },
    maps={
        backspace='backspace',
        newline='newline',
        space='space',
    },
    filters={
        alpha='alpha',
        cmdtype='cmdtype',
        filter='filter',
        escape='escape',
        filetype='filetype',
        tsnode='tsnode',
    },
    alpha={
        __inherit_keys={'basefilter'},
        before='boolean',
        after='boolean',
        py_fstr='boolean',
    },
    cmdtype={
        __inherit_keys={'basefilter'},
        skip='array_of_strings',
    },
    escape={
        __inherit_keys={'basefilter'},
        escapechar='string'
    },
    filetype={
        __inherit_keys={'basefilter'},
        ft='array_of_strings',
        nft='array_of_strings',
        detect_after='TODO',
        lang_detect_after='TODO',
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
    },
    basefilter={
        modes='modes',
        p='number',
    },
    backspace={
        __inherit_keys={'basemap'},
        overjump='TODO',
    },
    space={
        __inherit_keys={'basemap'},
    },
    newline={
        __inherit_keys={'basemap'},
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
    array_of_strings={ --Should be inlined
        __array_value='string',
    },
    TODO={
        __type='special',
    }
}
function M.validate(conf,spec_name,traceback)
    local spec=M.conf_spec[spec_name]
    if spec.__type=='type' then
        assert(type(conf)==spec.__data,('\n\n\n'..[[
        Configuration for the plugin 'ultimate-autopair' is incorrect.
        The option `%s` has the value `%s`, which has the type `%s`.
        However, that option should have the type `%s`.
        ]]..'\n'):format(traceback,conf,type(conf),spec.__data))
        return
    elseif spec.__type=='enum' then
        for _,v in ipairs(spec.__data --[[@as table]]) do
            if v==conf then
                return
            end
        end
        error(('\n\n\n'..[[
        Configuration for the plugin 'ultimate-autopair' is incorrect.
        The option `%s` contains the value `%s`.
        However, that option should be one of `%s`.
        ]]..'\n'):format(traceback,conf,vim.inspect(spec.__data)))
    elseif spec.__type=='special' then
        return
    end
    if type(conf)~='table' then
        error(('\n\n\n'..[[
        Configuration for the plugin 'ultimate-autopair' is incorrect.
        The option `%s` has the value `%s`, which has the type `%s`.
        However, the option should be a table.
        ]]..'\n'):format(traceback,vim.inspect(conf),type(conf)))

    end
    local tspec=setmetatable({merge='boolean'},{__index=spec})
    local inherit=vim.deepcopy(tspec.__inherit_keys or {})
    while #inherit>0 do
        local i_spec_name=table.remove(inherit)
        local ispec=M.conf_spec[i_spec_name]
        if ispec.__inherit_keys then
            vim.list_extend(inherit,ispec.__inherit_keys)
        end
        for k,v in pairs(ispec) do
            tspec[k]=tspec[k] or v
        end
    end
    if tspec.__array_value then
        for k,_ in ipairs(conf) do
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
        assert(tspec[k],('\n\n\n'..[[
        Configuration for the plugin 'ultimate-autopair' is incorrect.
        The option '%s' is set, but it should not be set.
        ]]..'\n'):format(traceback and traceback..'.'..convert(k) or convert(k)))
        M.validate(v,tspec[k],traceback and traceback..'.'..convert(k) or convert(k))
    end
end
function M.generate_random(spec_name)
    local out={}
    local spec=M.conf_spec[spec_name]
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
        else
            error''
        end
    elseif spec.__type=='enum' then
        return spec.__data[math.random(#spec.__data)]
    elseif spec.__type=='special' then
        return 'S'
    end
    local tspec=setmetatable({merge='boolean'},{__index=spec})
    local inherit=vim.deepcopy(tspec.__inherit_keys or {})
    while #inherit>0 do
        local i_spec_name=table.remove(inherit)
        local ispec=M.conf_spec[i_spec_name]
        if ispec.__inherit_keys then
            vim.list_extend(inherit,ispec.__inherit_keys)
        end
        for k,v in pairs(ispec) do
            tspec[k]=tspec[k] or v
        end
    end
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
return M
