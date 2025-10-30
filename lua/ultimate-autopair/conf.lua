local utils=require'ultimate-autopair.utils'
local M={}

local traceback_list_mt={}

local default_key={}

local filter_modules={
    filetype=require'ultimate-autopair.filter.filetype',
    tsnode=require'ultimate-autopair.filter.tsnode',
    cmdtype=require'ultimate-autopair.filter.cmdtype',
    escape=require'ultimate-autopair.filter.escape',
    alpha=require'ultimate-autopair.filter.alpha',
}

---@class ua.conf.traceback_list

---@class ua.conf.env
---@field traceback string
---@field vars table<string,any>
---@field hop_traceback boolean?
local env_={}

---@class ua.conf.opts
---@field validate number
---@field err_format ua.conf.err_format
local opts_={}

--- ;;; errors

---@alias ua.conf.err_format
---| 'table'
---| 'minimal'
---| 'borderless'
---| 'default'
---| table

---@alias ua.conf.err_type
---|'dont_set'
---|'vtype'
---|'enum'
---|'not_list'
---|'func_n_params'
---|'not_detected'
---|'need_set'
---|'same_type'

---@class ua.conf.err.dont_set
---@field type 'dont_set'
---@field idx any
---@field option_names string[]

---@class ua.conf.err.vtype
---@field type 'vtype'
---@field wants_val any[]
---@field wants_type string[]

---@class ua.conf.err.enum
---@field type 'enum'
---@field enums any[]

---@class ua.conf.err.not_list
---@field type 'not_list'

---@class ua.conf.err.func_n_params
---@field type 'func_n_params'
---@field wanted_nparams_min number
---@field wanted_nparams_max number

---@class ua.conf.err.not_detected
---@field type 'not_detected'
---@field subtype 'filetype'|'TSNode'|'TSNode_filetype'|'query_filetype'|'tslang'
---@field msg string

---@class ua.conf.err.need_set
---@field type 'need_set'
---@field valid string[]

---@class ua.conf.err.same_type
---@field type 'same_type'
---@field traceback1 string
---@field traceback2 string
---@field opt1 any
---@field opt2 any

---@alias ua.conf.err
---|ua.conf.err.need_set
---|ua.conf.err.dont_set
---|ua.conf.err.vtype
---|ua.conf.err.enum
---|ua.conf.err.not_list
---|ua.conf.err.func_n_params
---|ua.conf.err.not_detected
---|ua.conf.err.same_type

---@type table<ua.conf.err_type,number|table<string,number>>
local err_severity={
    vtype=1,
    enum=1,
    need_set=1,
    not_detected={
        ['TSNode']=1,
        ['TSNode_filetype']=1,
        ['query_filetype']=1,
        ['filetype']=3,
        ['tslang']=3,
    },
    same_type=1,
    dont_set=2,
    not_list=2,
    func_n_params=3,
}

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

---@param val any
---@param err ua.conf.err
---@return string
local function generate_error_message(val,err)
    local function obj_to_str(obj)
        return type(obj)=='string' and ('%q'):format(obj) or tostring(obj)
    end
    local traceback=env_.traceback
    local traceback_with_val=('`%s` (with the value `%s`)'):format(traceback,obj_to_str(val))
    if err.type=='dont_set' then
        local suggestion=''
        if err.option_names and type(err.idx)=='string' then
            local possible={}
            for _,optname in ipairs(err.option_names) do
                if type(optname)=='string' then
                    ---Numbers and limit from python name-error suggestion algorithm
                    ---@see https://docs.python.org/3.10/whatsnew/3.10.html#nameerrors
                    local limit=(#(err.idx)+#optname+3)*2/6
                    if levenshtein(optname,err.idx)<limit then
                        table.insert(possible,optname)
                    end
                end
            end
            if #possible>0 then
                suggestion=('Did you mean `%s`?'):format(table.concat(possible,'`, `'))
            end
        end
        return ([[
        The option `%s` is set, but it should not be set.

        %s
        ]]):format(traceback,suggestion)
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
        ]]):format(traceback,table.concat(wantstrs,'\n        '),obj_to_str(val),type(val))
    elseif err.type=='enum' then
        return ([[
        The option `%s` contains the value `%s`.
        However, that option should be one of `%s`.
        ]]):format(traceback,obj_to_str(val),vim.inspect(err.enums))
    elseif err.type=='not_list' then
        return ([[
        The option `%s` should be a list (see `:help vim.islist()`).
        ]]):format(traceback)
    elseif err.type=='func_n_params' then
        local tonum={
            [0]='zero',
            [1]='one',
            [2]='two',
            [3]='three',
            [4]='four',
            [5]='five',
            [6]='six',
            [7]='seven',
            [8]='eight',
            [9]='nine',
        }
        local min_name=assert(tonum[err.wanted_nparams_min])
        local max_name=assert(tonum[err.wanted_nparams_max])
        local info=debug.getinfo(val,'u')
        return min_name==max_name and ([[
        The option `%s` is a function which should take %s and only %s argument%s.
        It currently takes %d%s argument%s.
        ]]):format(traceback,min_name,min_name,err.wanted_nparams_min~=1 and 's' or '',info.nparams,
                info.isvararg and ' or more' or '',(info.nparams~=1 or info.isvararg) and 's' or '')
        or ([[
        The option `%s` is a function which should take %s to %s arguments.
        It currently takes %d%s argument%s.
        ]]):format(traceback,min_name,max_name,info.nparams,
                info.isvararg and ' or more' or '',(info.nparams~=1 or info.isvararg) and 's' or '')
    elseif err.type=='not_detected' then
        return ([[
        The option %s is not detected as a %s.
        ]]):format(traceback_with_val,err.msg)
    elseif err.type=='need_set' and #err.valid==1 then
        return ([[
        The option `%s` requires the option `%s` to be set.
        ]]):format(traceback,err.valid[1])
    elseif err.type=='need_set' then
        local valid={}
        for _,v in ipairs(err.valid) do
            table.insert(valid,('  * `%s`'):format(v))
        end
        return ([[
        The option `%s` requires one of the following options to be set:
        %s
        ]]):format(traceback,table.concat(valid,'\n        '))
    elseif err.type=='same_type' then
        local traceback1_with_val=('`%s` (with the value `%s`)'):format(
            err.traceback1,obj_to_str(err.opt1))
        local traceback2_with_val=('`%s` (with the value `%s`)'):format(
            err.traceback2,obj_to_str(err.opt2))
        return ([[
        The options %s and %s should be of the same type.
        But they are of the types `%s` and `%s`.
        ]]):format(traceback1_with_val,traceback2_with_val,type(err.opt1),type(err.opt2))
    else
        error('unreachable')
    end
end

---@param err ua.conf.err
---@param val any
local function error_it(val,err)
    --TODO: rewrod "POSSIBLY incorrect" to something better
    local severity=err_severity[err.type]
    if err.type=='not_detected' then
        severity=severity[err.subtype]
    end
    assert(severity<=opts_.validate)
    if opts_.err_format=='minimal' then
        error(('ultimate-autopair: config is%s invalid'):format(severity>=2 and ' POSSIBLY' or ''))
    end
    local msg=generate_error_message(val,err)
    msg=msg:gsub('^ *',''):gsub('\n *','\n'):gsub('\n+$','')
    local errdata={val=val,err=err,traceback=env_.traceback,msg=msg}
    if type(opts_.err_format)=='table' then
        if severity>=2 then
            table.insert(opts_.err_format --[[@as table]],errdata)
            return
        else
            error(errdata)
        end
    elseif opts_.err_format=='table' then
        error(errdata)
    end
    local m=vim.split(msg,'\n')
    table.insert(m,1,'')
    local top=('Configuration for the plugin \'ultimate-autopair\' is%s incorrect:'):format(severity>=2 and ' POSSIBLY' or '')
    table.insert(m,1,top)
    --TODO
    --if env_.help then
    --    table.insert(m,'')
    --    table.insert(m,('See `:help %s` for more details.'):format(env_.help))
    --end
    if opts_.err_format=='borderless' then
        error('\n\n\n'..table.concat(m,'\n')..'\n\n')
    end
    assert(opts_.err_format=='default')
    local max_len=0
    for _,v in ipairs(m) do
        max_len=math.max(max_len,#v)
    end
    local border=('-'):rep(math.min(max_len,vim.o.columns-1))
    table.insert(m,1,border)
    table.insert(m,border)
    error('\n\n\n'..table.concat(m,'\n')..'\n\n')
end

--- ;;; asserts
---@param x any
---@param types type[]|type
---@param vals (any[])?
local function assert_is(x,types,vals)
    if opts_.validate<err_severity.vtype then return end
    if type(types)~='table' then types={types} end
    ---@cast types string[]
    assert((#types*2+#(vals or {}))>=2)
    for _,v in ipairs(vals or {}) do
        if x==v then return end
    end
    for _,v in ipairs(types) do
        if type(x)==v then return end
    end
    error_it(x,{
        type='vtype',
        wants_val=vals or {},
        wants_type=types,
    })
end
---@param x any
local function assert_is_list(x)
    assert_is(x,'table')
    if opts_.validate<err_severity.not_list then return end
    if not vim.islist(x) then
        error_it(x,{
            type='not_list',
        })
    end
end
---@param x any
---@param enums any[]
local function assert_in_enum(x,enums)
    if opts_.validate<err_severity.enum then return end
    for _,v in ipairs(enums) do
        if x==v then return end
    end
    error_it(x,{
        type='enum',
        enums=enums,
    })
end
---@param fn function
---@param wanted_nparams number
---@param wanted_nparams_max number?
local function assert_n_params(fn,wanted_nparams,wanted_nparams_max)
    wanted_nparams_max=wanted_nparams_max or wanted_nparams
    if opts_.validate<err_severity.func_n_params then return end
    local info=debug.getinfo(fn,'u')
    if info.nparams<=wanted_nparams_max
        and (info.nparams>=wanted_nparams or info.isvararg) then
        return
    end
    error_it(fn,{
        type='func_n_params',
        wanted_nparams_min=wanted_nparams,
        wanted_nparams_max=wanted_nparams_max,
    })
end
local other_filetypes={'TelescopePrompt','fzf','skim','snacks_picker_input'}
---@param ft any
local function assert_filetype(ft)
    assert_is(ft,'string')
    ---@cast ft string
    if opts_.validate<err_severity.not_detected.filetype then return end
    if vim.treesitter.language.add(vim.treesitter.language.get_lang(ft) or '') then
    elseif utils.in_list(vim.fn.getcompletion('','filetype'),ft) then
    elseif utils.in_list(other_filetypes,ft) then
    else
        error_it(ft,{
            type='not_detected',
            subtype='filetype',
            msg='filetype',
        })
    end
end

---@param tslang any
local function assert_tslang(tslang)
    assert_is(tslang,'string')
    ---@cast tslang string
    if opts_.validate<err_severity.not_detected.tslang then return end
    if type(tslang)=='string' and vim.treesitter.language.add(tslang) then
    else
        error_it(tslang,{
            type='not_detected',
            subtype='tslang',
            msg='treesitter language',
        })
    end
end

---@param node string
local function assert_is_ts_node(node)
    assert_is(node,'string')
    if opts_.validate<err_severity.not_detected.TSNode then return end
    if not node:match('^[-a-zA-Z0-9_][-a-zA-Z0-9._]*$') then
        error_it(node,{
            type='not_detected',
            subtype='TSNode',
            msg='valid TSNode type',
        })
    end
end

---@param ft string
---@param node string
local function assert_is_ts_node_in_filetype(ft,node)
    assert_is_ts_node(node)
    if opts_.validate<err_severity.not_detected.TSNode_filetype then return end
    if pcall(vim.treesitter.query.parse,ft,('(%s)'):format(node)) then
    else
        error_it(node,{
            type='not_detected',
            subtype='TSNode_filetype',
            msg='valid TSNode type for filetype '..ft,
        })
    end
end

---@param ft string
---@param query string
local function assert_is_query_in_filetype(ft,query)
    assert_is(query,'string')
    if opts_.validate<err_severity.not_detected.query_filetype then return end
    if pcall(vim.treesitter.query.parse,ft,query) then
    else
        error_it(query,{
            type='not_detected',
            subtype='query_filetype',
            msg='valid query for filetype '..ft,
        })
    end
end

---@generic T
---@param traceback1 string
---@param opt1 T
---@param traceback2 string
---@param opt2 T
local function assert_options_same_type(traceback1,opt1,traceback2,opt2)
    if opts_.validate<err_severity.same_type then return end
    if type(opt1)~=type(opt2) then
        error_it(nil,{
            type='same_type',
            traceback1=traceback1,
            traceback2=traceback2,
            opt1=opt1,
            opt2=opt2,
        })
    end
end

--- ;;; validate/generate
--- ;;;; validate/generate-utils
---@param idx any
---@param traceback string
---@param is_key boolean?
---@return string
local function merge_traceback(traceback,idx,is_key)
    if is_key then
        return traceback..'#index['..(type(idx)=='string' and ('%q'):format(idx) or tostring(idx))..']'
    end
    if type(idx)~='string' then
        return traceback..'['..tostring(idx)..']'
    elseif traceback=='' then
        return idx
    else
        return traceback..'.'..idx
    end
end
---@param idx any
---@param o table<string|boolean|number,any>
local function error_dont_set_idx(idx,o)
    if opts_.validate<err_severity.dont_set then return end
    local option_names={}
    for k in pairs(o) do
        table.insert(option_names,k)
    end
    local saved_env=env_
    env_=setmetatable({
        traceback=merge_traceback(env_.traceback,idx)
    },{__index=saved_env})
    error_it(nil,{
        type='dont_set',
        idx=idx,
        option_names=option_names,
    })
    env_=saved_env
end
---@generic T
---@param tbl table
---@param index any
---@param fn fun(arg:any):T
---@param default T?
---@return T
local function _apply_index(tbl,index,fn,default)
    if tbl[index]==nil then
        if default~=nil then
            return default
        end
        error('unreachable')
    end
    local saved_env=env_
    env_=setmetatable({},{__index=saved_env})
    if env_.hop_traceback then
        env_.hop_traceback=false
    else
        env_.traceback=merge_traceback(env_.traceback,index)
    end
    local ret=fn(tbl[index])
    assert((getmetatable(env_) or {}).__index==saved_env)
    env_=saved_env
    return ret
end
---@generic T: function|table|string|number|boolean|userdata|thread
---@param tbl table
---@param index any
---@param fn fun(arg:any):T
---@param default T
---@return T
local function apply_index_default(tbl,index,fn,default)
    return _apply_index(tbl,index,fn,default)
end
---@generic T
---@param tbl table
---@param index any
---@param fn fun(arg:any):T
---@return T?
local function apply_index_default_nil(tbl,index,fn)
    local obj={}
    local ret=_apply_index(tbl,index,fn,obj)
    if ret~=obj then return ret end
end
---@param tbl table
---@param index any
---@param fn fun(arg:any)
local function apply_index_default_noret(tbl,index,fn)
    _apply_index(tbl,index,fn,{})
end
---@generic T
---@param tbl table
---@param index any
---@param fn fun(arg:any):T
---@param traceback_list T|ua.conf.traceback_list?
---@return T|ua.conf.traceback_list
local function apply_index_traceback_list(tbl,index,fn,traceback_list)
    if getmetatable(traceback_list)~=traceback_list_mt and traceback_list~=nil then
        return _apply_index(tbl,index,fn,traceback_list)
    end
    if env_.hop_traceback then
    else
        local traceback=merge_traceback(env_.traceback,index)
        traceback_list=setmetatable({traceback,traceback_list},traceback_list_mt)
    end
    return _apply_index(tbl,index,fn,traceback_list)
end
---@generic T
---@param tbl table
---@param index any
---@param fn fun(arg:any):T
---@return T|ua.conf.traceback_list
local function apply_index_required(tbl,index,fn)
    local obj={}
    local ret=_apply_index(tbl,index,fn,obj)
    if ret==obj then
        error_it(nil,{
            type='need_set',
            valid={merge_traceback(env_.traceback,index)},
        })
    end
    return ret
end
---@param tbl table
---@param index any
---@param fn fun(arg:any)
local function apply_index_required_noret(tbl,index,fn)
    apply_index_required(tbl,index,fn)
end

---@generic T,G,H
---@param tbl table<G,H>
---@param fn fun(arg:any):T?
---@return T[]
local function map_apply_indexes(tbl,fn)
    local ret={}
    for idx in pairs(tbl) do
        ret[idx]=_apply_index(tbl,idx,fn)
    end
    return ret
end

---@generic T,G,H
---@param tbl table<G,H>
---@param index_fn fun(arg:G)
---@param fn fun(arg:H):T?
---@return T[]
local function map_apply_indexes_double(tbl,index_fn,fn,_ret)
    assert(not env_.hop_traceback)
    local ret=_ret or {}
    for index in pairs(tbl) do
        local saved_env=env_
        env_=setmetatable({},{__index=saved_env})
        env_.traceback=merge_traceback(env_.traceback,index,true)
        index_fn(index)
        assert((getmetatable(env_) or {}).__index==saved_env)
        env_=saved_env
        ret[index]=_apply_index(tbl,index,fn)
    end
    return ret
end

---@generic T
---@param t ua.conf.traceback_list|T
---@return T
local function detraceback(t)
    if getmetatable(t)==traceback_list_mt then
        local valid={}
        while t do
            table.insert(valid,t[1])
            t=t[2]
        end
        error_it(nil,{
            type='need_set',
            valid=valid,
        })
    end
    return t
end

---@generic T
---@param tbl table
---@param index any
---@param fn fun(arg:any):T
---@param traceback_list T|ua.conf.traceback_list
---@return T
local function apply_index_or_detraceback(tbl,index,fn,traceback_list)
    return detraceback(apply_index_traceback_list(tbl,index,fn,traceback_list))
end

---@class ua.conf.apply_index_tbl_opts.base
---@field [1] string|number|boolean
---@field [2] function
---@class ua.conf.apply_index_tbl_opts.detrace: ua.conf.apply_index_tbl_opts.base
---@field detrace any
---@class ua.conf.apply_index_tbl_opts.default: ua.conf.apply_index_tbl_opts.base
---@field default any
---@class ua.conf.apply_index_tbl_opts.default_nil: ua.conf.apply_index_tbl_opts.base
---@field default_nil true
---@class ua.conf.apply_index_tbl_opts.needed: ua.conf.apply_index_tbl_opts.base
---@field needed boolean
---@alias ua.conf.apply_index_tbl_opts
---|ua.conf.apply_index_tbl_opts.detrace
---|ua.conf.apply_index_tbl_opts.default
---|ua.conf.apply_index_tbl_opts.default_nil
---|ua.conf.apply_index_tbl_opts.needed

---@param tbl table
---@param idxs table<string|number|boolean,ua.conf.apply_index_tbl_opts|true>
---@param o table?
---@param _default table?
---@return table
local function apply_index_tbl(tbl,idxs,o,_default)
    local ret=_default or {}
    local keys={}
    for idx in pairs(tbl) do
        keys[idx]=true
        if idxs[idx]==true then
            goto continue
        end
        if not idxs[idx] then
            if rawget(o or {},idx) then
                goto continue
            end
            error_dont_set_idx(idx,idxs)
            goto continue
        end
        local rule=idxs[idx]
        local fn=rule[2]
        if rule.needed then
            ret[rule[1]]=apply_index_required(tbl,idx,fn)
        elseif rule.detrace then
            ret[rule[1]]=apply_index_or_detraceback(tbl,idx,fn,rule.detrace)
        elseif rule.default_nil then
            ret[rule[1]]=apply_index_default_nil(tbl,idx,fn)
        elseif rule.default~=nil then
            ret[rule[1]]=apply_index_default(tbl,idx,fn,rule.default)
        else
            error('unreachable')
        end
        ::continue::
    end
    for idx,rule in pairs(idxs) do
        if keys[idx] then
            goto continue
        end
        local fn=rule[2]
        if rule.needed then
            ret[rule[1]]=apply_index_required(tbl,idx,fn)
        elseif rule.detrace then
            ret[rule[1]]=apply_index_or_detraceback(tbl,idx,fn,rule.detrace)
        elseif rule.default_nil then
            ret[rule[1]]=apply_index_default_nil(tbl,idx,fn)
        elseif rule.default~=nil then
            ret[rule[1]]=apply_index_default(tbl,idx,fn,rule.default)
        else
            error('unreachable')
        end
        ::continue::
    end
    return ret
end

--- ;;;; validate/generate-validate/generate

--- c_*: check function, doesn't modify the input
--- g_*: generate function, modifies the input immutably
--- i_*: shared function, typically used when g_*/c_* functions would share most code
--- d_*: shared function, typically used by multiple g_*/c_* functions
--- cc_*/gg_*: returns a c_*/g_* function, basically a curried version of i_*

---@param n number
---@return number
local function c_number(n)
    assert_is(n,'number')
    return n
end

---@param b boolean
---@return boolean
local function c_boolean(b)
    assert_is(b,'boolean')
    return b
end

---@param ft string
---@return string
local function c_is_filetype(ft)
    assert_filetype(ft)
    return ft
end

---@param s string
---@return string
local function c_string(s)
    assert_is(s,'string')
    return s
end

---@param filetypes ua.config.filetypes
local function g_filetypes(filetypes)
    assert_is(filetypes,{'table','string'})
    if type(filetypes)=='string' then
        filetypes={filetypes}
        env_.hop_traceback=true
    end
    assert_is_list(filetypes)
    return map_apply_indexes(filetypes,c_is_filetype)
end

---@param filetype_getopt ua.config.use_filetype_getopt
---@return ua.iconfig.use_filetype_getopt
local function g_use_filetype_getopt(filetype_getopt)
    assert_is(filetype_getopt,{'boolean','table','function'})
    if type(filetype_getopt)=='boolean' then
        return {[true]=filetype_getopt}
    elseif type(filetype_getopt)=='function' then
        assert_n_params(filetype_getopt,2)
        return {[true]=filetype_getopt}
    end
    local function c_entry(entry)
        assert_is(entry,{'boolean','function'})
        if type(entry)=='function' then
            assert_n_params(entry,2)
        end
        return entry
    end
    assert (type(filetype_getopt)=='table')
    local ret=map_apply_indexes_double(filetype_getopt,function (idx)
        assert_is(idx,'string',{true})
        if idx==true then return end
        assert_filetype(idx)
    end,c_entry)
    return ret
end

local modes_chars={'i','c','t','v','o','s','n'}
local modes_chars_and_true={'i','c','t','v','o','s','n',true}

---@param modes ua.config.modes
---@return ua.mode[]
local function c_modes(modes)
    assert_is(modes,{'table','string'})
    if type(modes)=='string' then
        modes={modes}
        env_.hop_traceback=true
    end
    assert_is_list(modes)
    return map_apply_indexes(modes,function (mode)
        assert_in_enum(mode,modes_chars)
        return mode
    end)
end

---@param hooks string|(string|ua.config.hook)[]
---@param is 'map'|'start pair'|'end pair'
---@return ua.iconfig.hook[]
local function i_hooks(hooks,is)
    assert_is(hooks,{'table','string'})
    if type(hooks)=='string' then
        hooks={hooks}
        env_.hop_traceback=true
    end
    assert_is_list(hooks)
    local ret_hooks_multimode=map_apply_indexes(hooks,function (hook)
        assert_is(hook,{'string','table'})
        ---@type ua.config.hook
        local o=vim.defaulttable(function (x) return x end)

        if type(hook)=='string' then
            if is=='end pair' then
                hook={utils.utf8sub(hook,1,1)}
            elseif is=='start pair' then
                hook={utils.utf8sub(hook,-1)}
            else
                hook={hook}
                assert(is=='map')
            end
            env_.hop_traceback=true
        end
        local ret_hook=apply_index_tbl(hook,{
            [1]={1,c_string,needed=true},
            [o.priority]={'priority',c_number,default=env_.vars.priority},
            [o.mode]={'mode',c_modes,detrace=is=='map' and env_.vars.map_modes or env_.vars.pair_modes},
        })
        return ret_hook
    end)
    local ret_hooks={}
    for _,hook in ipairs(ret_hooks_multimode) do
        for _,mode in ipairs(hook.mode) do
            table.insert(ret_hooks,{
                mode=mode,
                [1]=hook[1],
                priority=hook.priority,
            })
        end
    end
    return ret_hooks
end

---@param hooks string|(string|ua.config.hook)[]
---@return ua.iconfig.hook[]
local function g_start_pair_hook(hooks)
    return i_hooks(hooks,'start pair')
end

---@param hooks string|(string|ua.config.hook)[]
---@return ua.iconfig.hook[]
local function g_end_pair_hook(hooks)
    return i_hooks(hooks,'end pair')
end

---@param pair string|ua.dynamic_pair_fn
---@return string|ua.dynamic_pair_fn
local function c_pair_str(pair)
    assert_is(pair,{'string','function'})
    if type(pair)=='function' then
        --TODO: maybe make it a possible to do "1 to 2 arguments" instead of just "2 and only 2 arguments"
        assert_n_params(pair,2)
    end
    table.insert(env_.vars.pair_pair_opts,env_.traceback)
    table.insert(env_.vars.pair_pair_opts,pair)
    return pair
end

local g_filters_1
local g_filters_2
---@param tbl ua.config.base_map
---@return ua.iconfig.map
local function g_map(tbl)
    assert_is(tbl,'table')
    ---@type ua.iconfig.map.root
    local root=env_.vars.map_source[env_.vars.map_idx]
    if not root then
        local traceback
        if env_.vars.map_idx==default_key then
            traceback=env_.vars.map_opt
        else
            traceback=merge_traceback(env_.vars.map_opt,env_.vars.map_idx)
        end
        error_it(nil,{
            type='need_set',
            valid={traceback},
        })
    end
    assert(root.hooks)
    assert(root.filter)
    for idx in pairs(tbl) do
        if (root[idx]==nil or idx=='hooks') and idx~='enable' then
            local o={enable=true}
            for k in pairs(root) do
                if k=='hooks' then
                else
                    o[k]=k
                end
            end
            error_dont_set_idx(idx,o)
        end
    end
    local merge={}
    for idx,root_val in pairs(root) do
        if idx=='hooks' then
        elseif tbl[idx]==nil then
            merge[idx]=root_val
        elseif idx=='filters' then
            error'TODO'
        else
            merge[idx]=tbl[idx]
        end
    end
    return merge
end

---@param pair ua.config.pair_no_12
---@param map_opt any
---@param fn function
---@param map_multi_opt any
---@param default table?
---@return table<any,ua.iconfig.map>?
local function d_pair_map(pair,map_opt,fn,map_multi_opt,default)
    env_.vars.map_source=assert(env_.vars[map_opt])
    --TODO: env_.vars.map_filter
    local ret=apply_index_default(pair,map_multi_opt,function (tbl)
        assert_is(tbl,'table')
        return map_apply_indexes_double(tbl,function (idx)
            env_.vars.map_opt=map_multi_opt
            env_.vars.map_idx=idx
            end,fn,default)
    end,default or {})
    env_.vars.map_opt=map_opt
    env_.vars.map_idx=default_key
    ret[default_key]=apply_index_default(pair,map_opt,fn,false) or ret[default_key]

    return next(ret) and ret
end

---@param pair ua.config.single_pair|string
---@param is_end boolean
---@return ua.iconfig.single_pair
local function i_single_pair(pair,is_end)
    assert_is(pair,{'string','table'})
    ---@type ua.config.single_pair
    local o=vim.defaulttable(function (x) return x end)

    if type(pair)=='string' then
        env_.hop_traceback=true
        pair={pair,pair}
    end
    local pair_fallback
    if type(pair[1])=='string' and pair[2]==nil then
        pair_fallback=pair[1]
        table.insert(env_.vars.pair_pair_opts,env_.traceback)
        table.insert(env_.vars.pair_pair_opts,pair_fallback)
    end

    local modes=apply_index_traceback_list(pair,o.mode,c_modes,env_.vars.pair_modes)
    local priority=apply_index_default(pair,o.priority,c_number,env_.vars.priority)

    local backspace=d_pair_map(pair,o.backspace,g_map,o.backspace_multi,env_.vars.pair_backspace)
    local newline=d_pair_map(pair,o.newline,g_map,o.newline_multi,env_.vars.pair_newline)
    local space=d_pair_map(pair,o.space,g_map,o.space_multi,env_.vars.pair_space)

    local treesitter_enabled=apply_index_default_nil(pair,o.treesitter,c_boolean)
    if treesitter_enabled==nil then
        treesitter_enabled=env_.vars.pair_treesitter_enabled
    end

    env_.vars=setmetatable({
        pair_modes=modes,
        priority=priority,
    },{__index=env_.vars})

    return apply_index_tbl(pair,{
        [1]={'hooks',is_end and g_end_pair_hook or g_start_pair_hook,needed=true},
        [2]={'pair',c_pair_str,needed=not pair_fallback,default=pair_fallback},
        [o.multiline]={'multiline',c_boolean,default=env_.vars.multiline},
        [o.filter]={'filter',g_filters_1,default=env_.vars.pair_filters},
        [o.smart_pairing]={'smart_pairing',c_boolean,default=env_.vars.smart_pairing},
    },o,{
            backspace=backspace,
            newline=newline,
            space=space,
            treesitter=treesitter_enabled,
        })
end
---@param pair ua.config.single_pair
---@return ua.iconfig.single_pair
local function g_single_pair_start(pair)
    return i_single_pair(pair,false)
end

---@param pair ua.config.single_pair
---@return ua.iconfig.single_pair
local function g_single_pair_end(pair)
    return i_single_pair(pair,true)
end

---@param pair ua.config.pair
---@return ua.iconfig.pair
local function g_pair(pair)
    assert_is(pair,'table')
    ---@type ua.config.pair
    local o=vim.defaulttable(function (x) return x end)

    local modes=apply_index_traceback_list(pair,o.mode,c_modes,env_.vars.pair_modes)
    local priority=apply_index_default(pair,o.priority,c_number,env_.vars.priority)
    local multiline=apply_index_default(pair,o.multiline,c_boolean,env_.vars.multiline)
    local filters=apply_index_default(pair,o.filter,g_filters_1,{inherited=env_.vars.root_filters})
    local smart_pairing=apply_index_default(pair,o.smart_pairing,c_boolean,env_.vars.smart_pairing)
    _G.a=pair.treesitter==false
    local treesitter_enabled=apply_index_default_nil(pair,o.treesitter,c_boolean)
    _G.a=false

    local backspace=d_pair_map(pair,o.backspace,g_map,o.backspace_multi)
    local newline=d_pair_map(pair,o.newline,g_map,o.newline_multi)
    local space=d_pair_map(pair,o.space,g_map,o.space_multi)

    env_.vars=setmetatable({
        pair_modes=modes,
        priority=priority,
        multiline=multiline,
        pair_filters=filters,
        smart_pairing=smart_pairing,
        pair_backspace=backspace,
        pair_space=space,
        pair_newline=newline,
        pair_treesitter_enabled=treesitter_enabled,
        pair_pair_opts={},
    },{__index=env_.vars})
    local ipair=apply_index_tbl(pair,{
        [1]={'start_pair',g_single_pair_start,needed=true},
        [2]={'end_pair',g_single_pair_end,needed=true},
    },o)
    assert_options_same_type(unpack(env_.vars.pair_pair_opts))
    return ipair
end

---@param x string
---@return fun(b:boolean|string):boolean|string
local function cc_boolean_or_string(x)
    return function (b)
        assert_is(b,'boolean',{x})
        return b
    end
end

---@param hooks string|(string|ua.config.hook)[]
---@return ua.iconfig.hook[]
local function g_hooks(hooks)
    return i_hooks(hooks,'map')
end

local function g_cmdtype_skip(skips)
    assert_is(skips,{'table','string'})
    if type(skips)=='string' then
        skips={skips}
        env_.hop_traceback=true
    end
    assert_is_list(skips)
    return map_apply_indexes(skips,function (x)
        assert_in_enum(x,{'',':','>','/','?','@','-','='})
        return x
    end)
end

local function c_boolean_string(x)
    assert_is(x,{'boolean','string'})
    return x
end

local function g_tsnode_queries(tbl)
    assert_is(tbl,'table')
    local ft
    map_apply_indexes_double(tbl,function (x)
        assert_tslang(x)
        ft=x
    end,function (x)
            assert_is_query_in_filetype(ft,x)
            return x
        end)
end

---@type (ua.config.nodeclass|true)[]
local _nodeclasses={'string','comment',true}
---@return table<ua.config.nodeclass|true,false|'separate'|'exclude'>
local function g_tsnode_nodeclass(nodeclass)
    assert_is(nodeclass,'table')
    return map_apply_indexes_double(nodeclass,function (x)
        assert_in_enum(x,_nodeclasses)
    end,function (x)
            assert_in_enum(x,{'separate','exclude',false})
            return x
        end)
end

local function g_nodes(nodes)
    assert_is(nodes,{'table','string'})
    if type(nodes)=='string' then
        assert_is_ts_node(nodes)
        return {nodes}
    end
    local ft
    map_apply_indexes_double(nodes,function (x)
        assert_is(x,{'string','number'})
        if type(x)=='string' then
            assert_tslang(x)
            ft=x
        else
            ft=nil
        end
    end,function (x)
            if ft==nil then
                assert_is_ts_node(x)
                return x
            end
            assert_is(x,{'string','table'})
            if type(x)=='string' then
                x={x}
                env_.hop_traceback=true
            end
            map_apply_indexes(x,function (y)
                assert_is_ts_node_in_filetype(ft,y)
            end)
            return x
        end)
end

local function cc_funcs(nargs)
    return function (fn)
        assert_is(fn,'function')
        assert_n_params(fn,nargs)
        return fn
    end
end


---@type table<string,table<ua.config.filters.name,ua.conf.apply_index_tbl_opts>>
local filter_opts={
    cmdtype={
        skip={'skip',g_cmdtype_skip,needed=true},
    },
    escape={
    },
    alpha={
        before={'before',c_boolean_string,default=false},
        after={'after',c_boolean_string,default=false},
        fstring_smart={'fstring_smart',c_boolean,default=true},
        insert_only={'insert_only',c_boolean,default=true},
    },
    filetype={
        ft={'ft',g_filetypes,default_nil=true},
        nft={'nft',g_filetypes,default_nil=true},
        treesitter={'treesitter',c_boolean,default=true},
        injectlang_separate={'injectlang_separate',c_boolean,default=true},
        temp_insert={'temp_insert',c_boolean,default=false},
    },
    tsnode={
        query={'query',g_tsnode_queries,default={}},
        nodeclass_filter={'nodeclass_filter',g_tsnode_nodeclass,default={}},
        separate={'separate',g_nodes,default={}},
        separate_inclusive={'separate_inclusive',g_nodes,default={}},
        exclude={'exclude',g_nodes,default={}},
        exclude_inclusive={'exclude_inclusive',g_nodes,default={}},
    },
    other={
        once={'once',cc_funcs(1),default_nil=true},
        on_iter={'on_iter',cc_funcs(1),default_nil=true},
        pos={'pos',cc_funcs(1),default_nil=true},
        on_iter_pos={'on_iter_pos',cc_funcs(1),default_nil=true},
        row={'row',cc_funcs(1),default_nil=true},
    }
}
local filter_names=vim.tbl_keys(filter_opts)

local g_filter_filetype
local g_filter_tsnode
local g_filter_cmdtype
local g_filter_escape
local g_filter_alpha
local g_filter_other
local g_filters

---@param filters ua.iconfig.filters
local function gg_filter_inherit(filters)
    ---@param tbl ua.config.filters.names|boolean
    ---@return ua.iconfig.filters
    return function (tbl)
        assert_is(tbl,{'table','boolean','string'})
        if tbl==false then
            return {}
        elseif tbl==true then
            return filters
        end
        if type(tbl)=='string' then
            tbl={tbl}
            env_.hop_traceback=true
        end
        ---TODO: an exclude option, similar to `default.exclude`
        assert_is_list(tbl)
        local inherit={}
        ---@cast tbl ua.config.filters.name[]
        map_apply_indexes(tbl,function (x)
            assert_in_enum(x,filter_names)
            inherit[x]=true
        end)
        local ret={}
        for _,v in pairs(filters) do
            if inherit[v._name] then
                table.insert(ret,v)
            end
        end
        return ret
    end
end

---@param tbl ua.config.filters.root
---@param opt any
---@param fn function
---@param multi_opt any
---@param collector ua.iconfig.filters
local function d_filters(tbl,opt,fn,multi_opt,collector)
    local tfn=assert(filter_modules[opt])
    ---@return false|ua.config.filter
    local function afn(idx)
        local val=apply_index_default(tbl,idx,fn,false)
        if val==false then return false end
        return tfn(val)
    end
    apply_index_default_noret(tbl,multi_opt,function (multi)
        assert_is_list(multi)
        for idx in ipairs(multi) do
            table.insert(collector,afn(idx) or nil)
        end
    end)
    table.insert(collector,afn(opt) or nil)
end

---@param tbl ua.config.filters.root
---@param type_ 0|1|2
---@return ua.iconfig.filters|ua.iconfig.filters.1|ua.iconfig.filters.2
local i_filters=function (tbl,type_)
    assert_is(tbl,'table')
    ---@type ua.config.filters.map_inherit
    local o=vim.defaulttable(function (x) return x end)

    ---@type ua.iconfig.filters
    local filters={}

    d_filters(tbl,o.filetype,g_filter_filetype,o.filetype_multi,filters)
    d_filters(tbl,o.tsnode,g_filter_tsnode,o.tsnode_multi,filters)
    d_filters(tbl,o.cmdtype,g_filter_cmdtype,o.cmdtype_multi,filters)
    d_filters(tbl,o.escape,g_filter_escape,o.escape_multi,filters)
    d_filters(tbl,o.alpha,g_filter_alpha,o.alpha_multi,filters)

    ---TODO: some kind of filter_or: if one filter fails, a second chance with these filters (same as filter's filter_or, but applied to multiple filters)
    ---TODO: some kind of filter_not: if passes, then the whole thing fails

    local enable=apply_index_default(tbl,o.enable,c_boolean,true)

    local inherited
    if type_==0 then
    elseif type_==1 then
        ---@cast filters ua.iconfig.filters.1
        inherited=apply_index_default(tbl,o.inherit_root_filters,
            gg_filter_inherit(env_.vars.root_filters),
            enable and env_.vars.root_filters or {})
    elseif type_==2 then
        ---@cast filters ua.iconfig.filters.2
        error('TODO')
    else
        error('unreachable')
    end

    for idx in pairs(tbl) do
        if rawget(o,idx) then
        elseif type(idx)=='number' then
            table.insert(filters,apply_index_default_nil(tbl,idx,g_filter_other))
        else
            error_dont_set_idx(idx,o)
        end
    end

    if enable==false then
        filters={}
    end

    filters.inherited=inherited

    return filters
end
---@param tbl ua.config.filters.root
---@return ua.iconfig.filters
function g_filters(tbl)
    return i_filters(tbl,0)
end

---@param tbl ua.config.filters.root_inherit
---@return ua.iconfig.filters.1
function g_filters_1(tbl)
    return i_filters(tbl,1) --[[@as ua.iconfig.filters.1]]
end

---@param tbl ua.config.filters.root_inherit
---@return ua.iconfig.filters.1
function g_filters_2(tbl)
    return i_filters(tbl,2) --[[@as ua.iconfig.filters.1]]
end

local filter_idxs={
    filter={'filter',g_filters,default_nil=true},
    filter_or={'filter_or',g_filters,default_nil=true},

    --TODO: a better name
    singlechar={'singlechar',c_boolean,default_nil=true},
    --TODO: some kind of filter_not, see other TODO for more info
}
local function gg_filter(extend)
    local idxs=vim.tbl_extend('error',filter_idxs,extend)
    ---@return ua.config.filter|false
    return function (tbl)
        assert_is(tbl,'table',{false})
        if tbl==false then
            return false
        end
        local enable=apply_index_default(tbl,'enable',c_boolean,true)
        local ret=apply_index_tbl(tbl,idxs,{enable=true})
        return enable==false and false or ret
    end
end

g_filter_filetype=gg_filter(filter_opts.filetype)
g_filter_tsnode=gg_filter(filter_opts.tsnode)
g_filter_cmdtype=gg_filter(filter_opts.cmdtype)
g_filter_escape=gg_filter(filter_opts.escape)
g_filter_alpha=gg_filter(filter_opts.alpha)
g_filter_other=gg_filter(filter_opts.other)

local function c_is_fastwarp_type(x)
    assert_in_enum(x,{'normal','treesitter','fast'})
    return x
end

---@param extend table<string,ua.conf.apply_index_tbl_opts|true>
local function gg_map_root(extend)
    local idxs=vim.tbl_extend('error',{
        map={'hooks',g_hooks,needed=true},
        enable={'enable',c_boolean,default=true},
        filter={'filter',g_filters_1,default={}},
        treesitter={'treesitter',c_boolean,default_nil=true},
    },extend)
    ---@param tbl ua.config.base_map.root
    ---@return ua.iconfig.map.root
    return function (tbl)
        assert_is(tbl,'table')
        ---@type ua.config.base_map.root
        local o=vim.defaulttable(function (x) return x end)
        local modes=apply_index_traceback_list(tbl,o.mode,c_modes,env_.vars.map_modes)
        local priority=apply_index_default(tbl,o.priority,c_number,env_.vars.priority)

        env_.vars=setmetatable({
            map_modes=modes,
            priority=priority,
        },{__index=env_.vars})
        return apply_index_tbl(tbl,idxs,o)
    end
end

local function gg_map_root_multi(fn)
    return function (tbl)
        assert_is(tbl,'table')
        return map_apply_indexes(tbl,fn)
    end
end

---@type table<string,table<string,ua.conf.apply_index_tbl_opts.default>>
local maps_root_opts={
    backspace={
        overjump={'overjump',cc_boolean_or_string('nonambiguous'),default=false},
        space={'space',cc_boolean_or_string('balanced'),default=false},
        newline={'newline',cc_boolean_or_string('indent_ignore'),default=false},
        single_delete={'single_delete',c_boolean,default=false},
    },
    newline={
    },
    space={
        check_box_ft={'check_box_ft',g_filetypes,default={}},
    },
    fastwarp={
        type={'type',c_is_fastwarp_type,default='normal'},
        r_enable={'r_enable',c_boolean,default=false},
    },
}

local g_backspace_root=gg_map_root(maps_root_opts.backspace)
local g_newline_root=gg_map_root(maps_root_opts.newline)
local g_space_root=gg_map_root(maps_root_opts.space)
--local g_fastwarp_root=gg_map_root(maps_opts.fastwarp) TODO: special handling for fastwarp
--TODO: for non root maps, inheriting...

---@param tbl ua.config.base_perf
---@return ua.config.base_perf
local function c_perf(tbl)
    return apply_index_tbl(tbl,{
        timeout={'timeout',c_number,default_nil=true},
        byte_limit={'byte_limit',c_number,default_nil=true},
        row_limit={'row_limit',c_number,default_nil=true},
    })
end

---@param tbl ua.config.perf
---@return ua.config.perf
local function c_root_perf(tbl)
    --TODO: what to do with this... (maybe just remove timeout...)
    return apply_index_tbl(tbl,{
        treesitter={'treesitter',c_perf,default_nil=true},
        smart_pairing={'smart_pairing',c_perf,default_nil=true},
        multiline={'multiline',c_perf,default_nil=true},
        timeout={'timeout',c_number,default_nil=true},
        byte_limit={'byte_limit',c_number,default_nil=true},
        row_limit={'row_limit',c_number,default_nil=true},
    })
end

---@param tbl ua.config.fallback
---@return ua.config.fallback
local function g_fallback(tbl)
    --TODO: normalize_map(vim.keycode) the keys, including `tbl[this part]`, but that may result in duplicates, so error if there are such duplicates
    return map_apply_indexes_double(tbl,
        function (idx)
            --TODO: if validate=2 then check whether there's a hook for that, and if there's no hook the error
            assert_is(idx,'string',{true})
        end,
        function (val)
            assert_is(val,{'string','function','table'},{true})
            if type(val)=='function' then
                assert_n_params(val,0)
            elseif type(val)=='table' then
                return map_apply_indexes_double(val,function (mode)
                    assert_in_enum(mode,modes_chars_and_true)
                end,function (val2)
                        assert_is(val2,{'string','function'},{true})
                        if type(val2)=='function' then assert_n_params(val2,0) end
                        return val2
                    end)
            end
            return val
        end)
end

---TODO: local treesitter switch (for both maps(global and pair-local) and pairs)

---@param tbl ua.config
---@return ua.iconfig
local function g_main(tbl)
    assert_is(tbl,'table')
    ---@type ua.config
    local o=vim.defaulttable(function (x) return x end)

    -- These are validated and used beforehand
    local _=o.validate
    local _=o.err_format
    local _=o.default
    local _=o.lazy

    local use_filetype_getopt=apply_index_default(tbl,o.use_filetype_getopt,g_use_filetype_getopt,{[true]=false})
    local fallback=apply_index_default(tbl,o.fallback,g_fallback,{[true]=false})
    local treesitter_async=apply_index_default(tbl,o.treesitter_async,c_boolean,false)
    local treesitter_enabled=apply_index_default(tbl,o.treesitter,c_boolean,true)

    local map_modes=apply_index_traceback_list(tbl,o.map_mode,c_modes,nil)
    local pair_modes=apply_index_traceback_list(tbl,o.pair_map_mode,c_modes,map_modes)
    local priority=apply_index_default(tbl,o.priority,c_number,0)
    local multiline=apply_index_default(tbl,o.multiline,c_boolean,false)
    local smart_pairing=apply_index_default(tbl,o.smart_pairing,c_boolean,true)
    local filters=apply_index_default(tbl,o.root_filter,g_filters,{})

    env_.vars=setmetatable({
        map_modes=map_modes,
        pair_modes=pair_modes,
        priority=priority,
        multiline=multiline,
        root_filters=filters,
        smart_pairing=smart_pairing,
    },{__index=env_.vars})

    local backspace=apply_index_default(tbl,o.backspace_multi,gg_map_root_multi(g_backspace_root),{})
    backspace[default_key]=apply_index_default_nil(tbl,o.backspace,g_backspace_root)
    local newline=apply_index_default(tbl,o.newline_multi,gg_map_root_multi(g_newline_root),{})
    newline[default_key]=apply_index_default_nil(tbl,o.newline,g_newline_root)
    local space=apply_index_default(tbl,o.space_multi,gg_map_root_multi(g_space_root),{})
    space[default_key]=apply_index_default_nil(tbl,o.space,g_space_root)

    env_.vars=setmetatable({
        backspace=backspace,
        newline=newline,
        space=space,
    },{__index=env_.vars})

    local perf=apply_index_default(tbl,o.perf,c_root_perf,{})

    local pairs_={}
    for idx in pairs(tbl) do
        if rawget(o,idx) then
        elseif type(idx)=='number' then
            table.insert(pairs_,apply_index_required(tbl,idx,g_pair))
        else
            error_dont_set_idx(idx,o)
        end
    end

    ---@type ua.iconfig
    return {
        treesitter=treesitter_enabled,
        treesitter_async=treesitter_async,
        backspace=backspace,
        newline=newline,
        space=space,
        pairs=pairs_,
        use_filetype_getopt=use_filetype_getopt,
        perf=perf,
        fallback=fallback,
    }
end

---@param conf ua.config
---@return number,ua.conf.err_format
local function get_opt_validate_and_err_format(conf)
    local validate=({[true]=2,[false]=0})[conf.validate==nil and true or conf.validate] or conf.validate
    if type(validate)~='number' then
        error('ultimate-autopair: option `.validate` needs to be number, boolean or nil')
    end
    local err_format=conf.err_format==nil and 'default' or conf.err_format
    if err_format~='default' and err_format~='minimal' and err_format~='borderless' and err_format~='table' and type(err_format)~='table' then
        error('ultimate-autopair: option `.err_format` needs to be one of "default", "minimal", "borderless", "table" or a table')
    end
    return validate,assert(err_format)
end
---@param conf ua.config
---@return ua.iconfig
function M._generate(conf,_alter_opts)
    local validate,err_format=get_opt_validate_and_err_format(conf)
    opts_=_alter_opts or {
        validate=validate,
        err_format=err_format,
    }
    env_={
        traceback='',
        vars={},
    }
    return g_main(conf)
end

--- ;;; default merge
local _cache_valid_opts
---@param conf ua.config
---@param default_config ua.config
---@return table<string|number,true>|boolean
---@return table<number,ua.config.pair_no_12>?
function M._generate_opt_default_validate(conf,default_config)
    local validate,err_format=get_opt_validate_and_err_format(conf)
    opts_={
        validate=validate,
        err_format=err_format,
    }
    env_={
        traceback='',
        vars={},
    }
    assert_is(conf,'table')

    ---@diagnostic disable-next-line: redundant-return-value
    return unpack(apply_index_default(conf,'default',function (default)
        assert_is(default,{'table','boolean','nil'})
        if type(default)=='boolean' then
            return {default}
        end

        if not _cache_valid_opts then
            local valid_opts,pair_to_key={},{}
            for k,v in pairs(default_config) do
                if type(k)=='number' then
                    local v1,v2=v[1],v[2]
                    if type(v1)=='table' then v1=v1[1] end
                    assert(type(v1)=='string' and type(v2)=='string')
                    table.insert(valid_opts,v1..v2)
                    pair_to_key[v1..v2]=k
                    goto continue
                elseif k=='filter' then
                    for k2 in pairs(v) do
                        assert(not valid_opts[k])
                        table.insert(valid_opts,'filter.'..k2)
                    end
                end
                table.insert(valid_opts,k)
                ::continue::
            end
            _cache_valid_opts={valid_opts,pair_to_key}
        end

        local valid_opts,pair_to_key=unpack(_cache_valid_opts)
        local included={}
        for k,v in pairs(default) do
            if k=='exclude' then
            elseif k=='pair' then
            elseif type(k)=='number' then
                apply_index_required(default,k,function (val)
                    ---@diagnostic disable-next-line: missing-return
                    assert_in_enum(val,valid_opts)
                end)
                included[pair_to_key[v] or v]=true
            else
                error_dont_set_idx(k,{exclude=true,pair=true})
            end
        end
        if apply_index_default(default,'exclude',function (val)
            assert_is(val,'boolean')
            return val
        end,false) then
            local old_included=included
            included={}
            for _,v in ipairs(valid_opts) do
                if old_included[v] then
                else
                    included[v]=true
                end
            end
        end
        return {included,apply_index_default_nil(default,'pair',function (val)
            local ret={}
            assert_is(val,'table')

            for k,v in pairs(val) do
                if pair_to_key[k] then
                    ---TODO: if this is bad, then the traceback will be unintelligible (maybe: if pair index outside, signal that it's default pair)
                    apply_index_required_noret(val,k,function (c)
                        assert_is(c,'table')
                    end)
                    ret[pair_to_key[k]]=v
                else
                    --TODO: replace it with a in enum, so the user knows what is allowed
                    error_dont_set_idx(k,pair_to_key)
                end
            end
            return ret
        end)}
    end,{true,{}}))
end

return M
