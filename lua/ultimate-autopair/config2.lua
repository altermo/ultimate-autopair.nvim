local utils=require'ultimate-autopair.utils'
local M={}

---@alias ua.conf.err_format
---| 'table'
---| 'none'
---| 'minimal'
---| 'borderless'
---| 'full'

---@alias ua.conf.err_type
---|'dont_set'
---|'vtype'
---|'enum'
---|'not_list'
---|'func_single_arg'
---|'not_filetype'
---|'empty_string'

---@class ua.conf.opts
---@field validate? number|boolean
---@field err_format? ua.conf.err_format|boolean|nil

---@class ua.conf.err
---@field type ua.conf.err_type
---@field env ua.conf.env
---@field idx string?
---@field option_names string[]?
---@field wants_type string[]?
---@field wants_val any[]?
---@field enums any[]?
---@field nparams number?

---@class ua.conf.env
---@field val any
---@field validate number
---@field err_format ua.conf.err_format
---@field traceback string
---@field providers table<string,any>
---@field providers_traceback table<string,{[number]:string,n:number}>

---- ;; error
---@see https://en.wikipedia.org/wiki/Levenshtein_distance
local function levenshtein(str1,str2)
    local substitution_cost=function (a,b)
        if a==b then return 0 end
        if string.lower(a)==string.lower(b) then return 1 end
        return 2
    end
    local d={}
    for i=0,#str1 do
        d[i]={[0]=i}
    end
    for i=0,#str2 do
        d[0][i]=i
    end
    for i=1,#str1 do
        for j=1,#str2 do
            d[i][j]=math.min(d[i-1][j]+2,
                d[i][j-1]+2,
                d[i-1][j-1]+substitution_cost(str1:sub(i,i),str2:sub(j,j)))
        end
    end
    return d[#str1][#str2]
end
---@param err ua.conf.err
---@return string
local function generate_error_message(err)
    local function obj_to_str(obj)
        return type(obj)=='string' and ('%q'):format(obj) or tostring(obj)
    end
    local traceback=err.env.traceback
    local val=err.env.val
    local traceback_with_val=('`%s` (with the value `%s`)'):format(traceback,obj_to_str(val))
    if err.type=='dont_set' then
        local suggestion=''
        if err.option_names then
            local possible={}
            for _,optname in ipairs(err.option_names) do
                ---Numbers and limit from python name-error suggestion algorithm
                ---@see https://docs.python.org/3.10/whatsnew/3.10.html#nameerrors
                local limit=(#(err.idx)+#optname+3)*2/6
                if levenshtein(optname,err.idx)<limit then
                    table.insert(possible,optname)
                end
            end
            if #possible>0 then
                suggestion=('Did you mean `%s`?'):format(table.concat(possible,'`, `'))
            end
        end
        return ([[
        The option %s is set, but it should not be set.

        %s
        ]]):format(traceback_with_val,suggestion)
    elseif err.type=='vtype' and #err.wants_val==0 and #err.wants_type==1 then
        return([[
        The option %s should be the type `%s`, but got a `%s`.
        ]]):format(traceback_with_val,err.wants_type[1],type(val))
    elseif err.type=='vtype' then
        local wantstrs={}
        for _,want in ipairs(err.wants_val) do
            local v=obj_to_str(want)
            local s=('the value `%s`'):format(v)
            table.insert(wantstrs,' * '..s)
        end
        for _,want in ipairs(err.wants_type) do
            local s=('the type `%s`'):format(want)
            table.insert(wantstrs,' * '..s)
        end
        return ([[
        The option `%s` should be either
        %s
        But got the value `%s` with the type `%s`.
        ]]):format(traceback,table.concat(wantstrs,'\n'),obj_to_str(val),type(val))
    elseif err.type=='enum' then
        return ([[
        The option `%s` contains the value `%s`.
        However, that option should be one of `%s`.
        ]]):format(traceback,obj_to_str(val),vim.inspect(err.enums))
    elseif err.type=='not_list' then
        return ([[
        The option `%s` should be a list (see `:help islist`).
        ]]):format(traceback)
    elseif err.type=='func_single_arg' then
        return ([[
        The option `%s` is a function which takes one and only one argument.
        It currently takes %d%s arguments.
        ]]):format(traceback,err.nparams)
    elseif err.type=='not_filetype' then
        return ([[
        The option %s is not detected as a filetype.
        ]]):format(traceback_with_val)
    elseif err.type=='empty_string' then
        return ([[
        The option %s should not be an empty string.
        ]]):format(traceback_with_val)
    else
        error('unreachable')
    end
end
---@type table<ua.conf.err_type,number>
local err_severity={
    vtype=1,
    enum=1,
    empty_string=1,
    dont_set=2,
    not_list=2,
    not_filetype=3,
    func_single_arg=4,
}
---@param err ua.conf.err
local function error_it(err)
    local severity=err_severity[err.type]
    assert(severity<=err.env.validate)
    if err.env.err_format=='none' then
        error('ultimate-autopair config validation failed')
    elseif err.env.err_format=='table' then
        error(err)
    elseif err.env.err_format=='minimal' then
        error('ultimate-autopair: option at `'..err.env.traceback..'` is incorrect')
    end
    local msg=generate_error_message(err)
    msg=msg:gsub('^ *',''):gsub('\n *','\n'):gsub('\n+$','')
    local m=vim.split(msg,'\n')
    table.insert(m,1,'')
    local top=('Configuration for the plugin \'ultimate-autopair\' is%s incorrect:'):format(severity>=2 and ' POSSIBLY' or '')
    table.insert(m,1,top)
    table.insert(m,1,'')
    table.insert(m,'')
    if err.env.err_format=='borderless' then
        local newmsg='\n\n'..table.concat(m,'\n')..'\n'
        error(newmsg)
    end
    local tab='    '
    local box_char={'|','-','+','+','+','+'}
    do
        local max_len=0
        for _,v in ipairs(m) do
            max_len=math.max(max_len,#v)
        end
        local len=vim.o.columns-1
        local line=box_char[2]:rep(max_len+#tab*2)
        while (#line+2)>len do
            tab=tab:sub(1,-2)
            line=box_char[2]:rep(max_len+#tab*2)
            if tab=='' then
                line=box_char[2]:rep(len-1)
                box_char=setmetatable({''},{__index=box_char})
                break
            end
        end
        for i,v in ipairs(m) do
            m[i]=box_char[1]..tab..v..(' '):rep(max_len-#v)..tab..box_char[1]
        end
        table.insert(m,1,box_char[3]..line..box_char[4])
        table.insert(m,box_char[5]..line..box_char[6])
    end
    local newmsg='\n\n\n'..table.concat(m,'\n')..'\n\n'
    error(newmsg)
end

--- ;; assert
---@param env ua.conf.env
---@param types string[]|string
---@param vals string[]|string?
local function assert_is(env,types,vals)
    if env.validate<err_severity.vtype then return end
    if type(types)~='table' then types={types} end
    ---@cast types string[]
    if type(vals)~='table' then vals={vals} end
    ---@cast vals string[]
    assert((#types*2+#vals)>=2)
    for _,v in ipairs(vals) do
        if env.val==v then return end
    end
    for _,v in ipairs(types) do
        if type(env.val)==v then return end
    end
    error_it{
        type='vtype',
        env=env,
        wants_val=vals,
        wants_type=types,
    }
end
---@param env ua.conf.env
local function assert_is_list(env)
    assert_is(env,'table')
    if env.validate<err_severity.not_list then return end
    if not vim.islist(env.val) then
        error_it{
            type='not_list',
            env=env,
        }
    end
end
---@param env ua.conf.env
---@param enums any[]
local function assert_in_enum(env,enums)
    if env.validate<err_severity.enum then return end
    for _,v in ipairs(enums) do
        if env.val==v then return end
    end
    error_it{
        type='enum',
        env=env,
        enums=enums,
    }
end
---@param env ua.conf.env
---@param type_ string
local function assert_is_runtime(env,type_)
    assert_is(env,{'function',type_})
    if env.validate<err_severity.func_single_arg then return end
    if type(env.val)=='function' then
        local info=debug.getinfo(env.val,'u')
        if info.nparams==1 then
        elseif info.nparams==0 and info.isvararg==true then
        else
            error_it{
                type='func_single_arg',
                env=env,
                nparams=info.nparams,
            }
        end
    end
end
---@param env ua.conf.env
local function assert_filetype(env)
    assert_is(env,'string')
    if env.validate<err_severity.not_filetype then return end
    local ft=env.val
    if ft=='TelescopePrompt' then
    elseif type(ft)=='string' and vim.treesitter.language.add(vim.treesitter.language.get_lang(ft) or '') then
    else
        error_it{
            type='not_filetype',
            env=env,
        }
    end
end
---@param env ua.conf.env
local function assert_str_has_content(env)
    if env.val=='' then
        error_it{
            type='empty_string',
            env=env,
        }
    end
end

--- ;; merge (with default)
---@param conf any?
---@param default table
---@param spec table<string,table>
---@param top boolean
---@return any
local function merge_tbl(conf,default,spec,top)
    if conf==nil then
        return default
    elseif type(conf)~='table' then
        return conf
    elseif conf.merge==false then
        return conf
    end
    local out={}
    for k,v in pairs(default) do
        out[k]=v
    end
    for k,v in pairs(conf) do
        if spec[k] then
            out[k]=merge_tbl(v,default[k],spec[k],false)
        elseif type(k)=='number' then
            table.insert(out,v)
        elseif top and k=='change' then
            error('TODO')
        else
            out[k]=v
        end
    end
    return out
end
---@param conf ua.config?
---@param default ua.config.default
---@return ua.config
function M._merge_with_default(conf,default)
    return merge_tbl(conf,default,{
        filter={
            cmdtype={},
            escape={},
            alpha={},
            filetype={},
            tsnode={},
        },
        integration={},
        backspace={},
        newline={},
        space={},
        fastwarp={},
        fastwarp_treesitter={},
        fastwarp_fast={},
    },true)
end

--- ;; validate/generate
--- ;;; utils
---@return table<string,true>,fun(n:string):string
local function make_opts()
    local t={}
    return t,function (n)
        t[n]=true
        return n
    end
end
---@param idx string|number
---@param traceback string
---@return string
local function merge_traceback(traceback,idx)
    if type(idx)=='number' then
        return traceback..'['..tostring(idx)..']'
    elseif traceback=='' then
        return idx
    elseif type(idx)=='string' then
        return traceback..'.'..idx
    else
        error('unreachable')
    end
end
---@param env ua.conf.env
---@param idx string
---@param to table<string,any>
local function error_dont_set_idx(env,idx,to)
    ---@type ua.conf.env
    local nenv={
        val=env.val[idx],
        traceback=merge_traceback(env.traceback,idx),
        validate=env.validate,
        err_format=env.err_format,
        providers=env.providers,
        providers_traceback=env.providers_traceback,
    }
    local option_names={}
    for k in pairs(to) do
        table.insert(option_names,k)
    end
    error_it{
        env=nenv,
        type='dont_set',
        idx=idx,
        option_names=option_names,
    }
end
---@generic T
---@param env ua.conf.env
---@param idx string|number
---@param fn fun(env:ua.conf.env,...):T
---@param args table?
---@return T
local function apply_indexed(fn,env,idx,args)
    assert_is(env,'table')
    local new_val=env.val[idx]
    local traceback=merge_traceback(env.traceback,idx)
    ---@type ua.conf.env
    local new_env={
        val=new_val,
        traceback=traceback,
        validate=env.validate,
        err_format=env.err_format,
        providers=env.providers,
        providers_traceback=env.providers_traceback,
    }
    local ret=fn(new_env,unpack(args or {}))
    assert(ret~=nil) --TODO: is this needed?
    return ret
end

---@class ua.conf.mergef_spec
---@field match table<string,{[1]:(fun(env:ua.conf.env):any),[2]:any}>
---@field if_ table<any,any>
---@param spec ua.conf.mergef_spec
---@return fun(env:ua.conf.env):any
local function mergef(spec)
    return function (env)
        assert_is(env,'table',vim.tbl_keys(spec.if_ or {}))
        if spec.if_[env.val] then
            return spec.if_[env.val]
        end
        local out={}
        for idx in pairs(env.val) do
            if spec.match[idx]=='SKIP' then
            elseif spec.match[idx] then
                out[idx]=apply_indexed(spec.match[idx][1],env,idx,spec.match[idx][2])
            else
                error_dont_set_idx(env,idx,spec.match)
            end
        end
        return out
    end
end
---@param env ua.conf.env
---@param idx string
local function use(env,idx)
    local ret=env.providers[idx]
    if ret==nil then
        error('TODO: err')
    end
    return ret
end
---@param env ua.conf.env
---@param name string
---@param value any
---@param traceback string?
local function provide(env,name,value,traceback)
    if value then
        env.providers[name]=value
        env.providers=setmetatable({},{__index=env.providers})
    end
    if traceback then
        env.providers_traceback[name]=env.providers_traceback[name] or {n=1}
        env.providers_traceback[name][env.providers_traceback[name].n]=traceback
        env.providers_traceback[name].n=env.providers_traceback[name].n+1
        env.providers_traceback=setmetatable({},{__index=env.providers_traceback})
    else
        assert(env.providers[name]~=nil)
    end
end

--- ;;; generators
---@param env ua.conf.env
---@return string[]
local modes_generate=function (env)
    assert_is_list(env)
    local modes={}
    for idx in ipairs(env.val) do
        table.insert(modes,apply_indexed(function (nenv)
            assert_in_enum(nenv,{'i','c','t','x','o','s','n','v'})
            if nenv.val=='v' then
                return 'x'
            end
            return nenv.val
        end,env,idx))
    end
    return modes
end
---@param env ua.conf.env
---@return boolean|ua.conf.runtime_fn
local function rbool_generate(env)
    assert_is_runtime(env,'boolean')
    return env.val
end
---@param env ua.conf.env
---@return string[]
local function filetypes_generate(env)
    assert_is_list(env)
    local filetypes={}
    for idx in ipairs(env.val) do
        table.insert(filetypes,apply_indexed(function (nenv)
            assert_filetype(nenv)
            return env.val
        end,env,idx))
    end
    return filetypes
end
--- ;;; filter
local filter_base={
    match={
        enable={rbool_generate,true},
        merge='SKIP',
    },
    if_={
        [false]={enable=false},
        [true]={enable=true}
    },
}
local filter_escape_generate=mergef(setmetatable({--[[TODO]]},{__index=filter_base}))
local filter_alpha_generate=mergef(setmetatable({--[[TODO]]},{__index=filter_base}))
local filter_filetype_generate=mergef(setmetatable({match={
    treesitter={rbool_generate,false},
    detect_after={rbool_generate,false},
    nft={filetypes_generate,{}},
    ft={filetypes_generate,{}},
    ---TODO
}},{__index=filter_base}))
local filter_tsnode_generate=mergef(setmetatable({--[[TODO]]},{__index=filter_base}))
local filter_cmdtype_generate=mergef(setmetatable({match={
    skip={function (env)
        assert_is_list(env)
        local skips={}
        for idx in ipairs(env.val) do
            table.insert(skips,apply_indexed(function (nenv)
                assert_in_enum(nenv,{'',':','>','/','?','@','-','='})
                return nenv.val
            end,env,idx))
        end
        return skips
    end,{}}
}},{__index=filter_base}))
---@param env ua.conf.env
local function filter_generate(env)
    local to,o=make_opts()
    assert_is(env,'table')
    local filters={
        [o'cmdtype']={},
        [o'escape']={},
        [o'alpha']={},
        [o'filetype']={},
        [o'tsnode']={},
    }
    local function is_filter(idx,map)
        return idx==map or idx:match('^'..map..'_[%d_-]*$')
    end
    for idx in pairs(env.val) do
        if is_filter(idx,'cmdtype') then
            table.insert(filters.cmdtype,apply_indexed(filter_cmdtype_generate,env,idx))
        elseif is_filter(idx,'escape') then
            table.insert(filters.escape,apply_indexed(filter_escape_generate,env,idx))
        elseif is_filter(idx,'alpha') then
            table.insert(filters.escape,apply_indexed(filter_alpha_generate,env,idx))
        elseif is_filter(idx,'filetype') then
            table.insert(filters.filetype,apply_indexed(filter_filetype_generate,env,idx))
        elseif is_filter(idx,'tsnode') then
            table.insert(filters.filetype,apply_indexed(filter_tsnode_generate,env,idx))
        elseif idx~='merge' then
            error_dont_set_idx(env,idx,to)
        end
    end
    return filters
end

---@param env ua.conf.env
---@return ua.iconfig
local function main_generate_(env)
    assert_is(env,'table')
    ---@type ua.iconfig
    local out={} --[[@as unknown]]
    local to
    do
        local o
        to,o=make_opts()
        o'validate'
        o'merge'
        --env.top.map_modes=m(modes_generate,env,o'map_modes',NEEDED) --TODO: this is only needed when a map is created: create a system which handles needed config, for example if each map defines it's own config(mode), then this config doesn't need to be set, and if one map doesn't define it's own config(mode) and this is also unset, then error with info about how at least one of the two options need to be set
        --env.top.pair_map_modes=m(modes_generate,env,o'pair_map_modes',env.top.map_modes)
        env.top.multiline=apply_indexed(rbool_generate,env,o'multiline',false)
        env.top.filters=apply_indexed(filter_generate,env,o'filter',{})
        --env.top.integration=m(integration_generate,env,o'integration',{})

        --out.use_filetype_getopt=m(use_filetype_getopt_generate,env,o'use_filetype_getopt',true)

        o'space'
        o'newline'
        o'backspace'
        o'fastwarp'
        o'fastwarp_treesitter'
        o'fastwarp_fast'
    end
    local function is_map(idx,map)
        return idx==map or idx:match('^'..map..'_[%d_-]*$')
    end
    for idx in pairs(env.val) do
        if type(idx)=='number' then
        elseif is_map(idx,'space') then
            error('TODO')
        elseif is_map(idx,'newline') then
            error('TODO')
        elseif is_map(idx,'backspace') then
            error('TODO')
        elseif is_map(idx,'fastwarp') or idx=='fastwarp_treesitter' or idx=='fastwarp_fast' then
            error('TODO')
        elseif not to[idx] then
            error_dont_set_idx(env,idx,to)
        end
    end
    error('TODO')
    return out
end

---@param env ua.conf.env
---@param is_end boolean
local function single_pair_generate(env,is_end)
    assert_is(env,{'string','table'})
    local function str_pair_to_key(pair)
        if is_end then
            return utils.utf8sub(pair,1,1)
        else
            return utils.utf8sub(pair,-1)
        end
    end
    if type(env.val)=='string' then
        assert_str_has_content(env)
        local key=str_pair_to_key(env.val)
        local modes=use(env,'pair_modes')
        local fallback=key
        local priority=use(env,'priority')
        local ret={}
        for _,mode in ipairs(modes) do
            table.insert(ret,{mode=mode,key,fallback=fallback,p=priority})
        end
        return {ret,env.val}
    else
        error('TODO')
    end
end

---@param env ua.conf.env
local function pair_generate(env)
    assert_is(env,'table')
    local start_pairs_map,start_pair=unpack(apply_indexed(single_pair_generate,env,1,{false}))
    local end_pairs_map,end_pair=unpack(apply_indexed(single_pair_generate,env,2,{true}))
    for idx in pairs(env.val) do
        if idx==1 or idx==2 then
        else
            error('TODO')
        end
    end
    return {
        start_pairs_map=start_pairs_map,
        end_pairs_map=end_pairs_map,
        start_pair=start_pair,
        end_pair=end_pair,
    }
end

---@param env ua.conf.env
local function main_generate(env)
    assert_is(env,'table')
    local map_modes,pair_map_modes
    if env.val.map_modes~=nil then
        map_modes=apply_indexed(modes_generate,env,'map_modes')
    end
    if env.val.pair_map_modes~=nil then
        pair_map_modes=apply_indexed(modes_generate,env,'pair_map_modes')
    end
    provide(env,'priority',0)
    provide(env,'modes',map_modes,'map_modes')
    provide(env,'pair_modes',map_modes,'map_modes')
    provide(env,'pair_modes',pair_map_modes,'pair_map_modes')
    for idx in pairs(env.val) do
        if type(idx)=='number' then
            --TODO: check that env.val as a list doesn't have gaps
        elseif idx=='map_modes' or idx=='pair_map_modes' then
        else
            error('TODO')
        end
    end
    local pairs_={}
    for idx in ipairs(env.val) do
        table.insert(pairs_,apply_indexed(pair_generate,env,idx))
    end
    error('TODO')
end

---@param conf ua.config?
---@param opts ua.conf.opts?
function M._generate(conf,opts)
    if conf==nil then conf={} end
    if opts==nil then opts={} end
    local validate=({[true]=2,[false]=0})[opts.validate==nil and true or opts.validate] or opts.validate
    local err_format=({[true]='full',[false]='minimal'})[opts.err_format==nil and true or opts.err_format] or opts.err_format
    ---@type ua.conf.env
    local env={
        val=conf,
        validate=validate,
        err_format=err_format,
        traceback='',
        providers={},
        providers_traceback={},
    }
    return main_generate(env)
end
utils=dofile'/home/user/.tmp/lua/ua-mini/lua/ultimate-autopair/utils.lua'
M._generate({
    map_modes={'i','c'},
    --pair_map_modes=nil, --If nil then same as `map_modes`
    --multiline=true,
    ---- enables use of `vim.filetype.get_option`, which may break other plugins
    --use_filetype_getopt=false,
    {'(',')'},
    {'[',']'},
    {'{','}'},
    --{'"','"',multiline=false,nft={'tex'}},
    --{{"'",alpha={before=true,py_fstr=true,lua_nstr=true}},"'",
    ----[[filter_on_insert=in_lisp TODO]]multiline=false,nft={'tex','rust'}},
    ----{'<!--','-->',ft={'markdown','html'}}, --TODO: temp
    ----{'"""','"""',ft={'python'}}, --TODO: temp
    ----{"'''","'''",ft={'python'}}, --TODO: temp
    ----{'```','```',ft={'markdown'}}, --TODO: temp
    --filter={
    --  cmdtype={skip={'/','?','@'}},
    --  escape={},
    --  alpha={},
    --  filetype={nft={'TelescopePrompt'},detect_after=true,treesitter=true},
    --  --tsnode={separate=comment_and_stringish_nodes}, --TODO
    --},
    --integration={
    --  endwise=true,
    --},
    --backspace={
    --  enable=true,
    --  map='<bs>',
    --  fallback='<bs>',
    --  overjump=false,
    --},
    --newline={
    --  enable=true,
    --  map='<cr>',
    --  fallback='<cr>',
    --},
    --space={
    --  enable=false,
    --  map='<space>',
    --  fallback='<space>',
    --},
    --fastwarp={
    --  type='normal',
    --  enable=false,
    --  fallback='',
    --  map='<A-e>',
    --  rmap='<A-E>',
    --},
    --fastwarp_treesitter={
    --  type='treesitter',
    --  enable=false,
    --  fallback='',
    --  map={'<A-C-e>',p=10},
    --  rmap={'<A-C-E>',p=10},
    --},
    --fastwarp_fast={
    --  type='fast',
    --  enable=false,
    --  fallback='',
    --  map='<A-C-e>',
    --  rmap='<A-C-E>',
    --},
  }) error('TODO: remove')
return M
