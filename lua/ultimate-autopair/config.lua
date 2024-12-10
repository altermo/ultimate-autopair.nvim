local utils=require'ultimate-autopair.utils'

---@class ua.confspec.spec
---@field __type 'special_table'|'same'|'separate'|'validate'|'mergef'|'enum'|'special'
---@field __enum (string[])?
---@field __match table<string,string|'SKIP'>?
---@field __fallback table<string,ua.confspec.NEEDED|any>?
---@field __options table<number|string,string|true>?
---@field __if table<any,any>?
---@field [1] fun(fns:ua.confspec.fns)?
---@field [2] fun(fns:ua.confspec.fns,conf:any)?

---@class ua.confspec.fns
---@field idxmerge fun(mergefn:string,idx:string|number|boolean,needed_fallback:ua.confspec.NEEDED|any,t:'list'|'deflist'?):table
---@field match fun(tbl:table<string,string|'SKIP'>,idx:string,out:table,needed_fallback:table<string,ua.confspec.NEEDED|any>?):boolean
---@field error fun(k:'DONTSET'|'NEEDED'|'TYPE'|'ENUM'|'VTYPE'|'NOLIST',...:any)
---@field assert_is fun(type:string|string[],val:(any[])?)
---@field assert_enum fun(tbl:string[])
---@field assert_is_runtime fun(type:string)
---@field assert_filetype fun()
---@field foridx fun():any
---@field forallidx fun(idxs:string[]):any
---@field get_env fun(env:string):any
---@field set_env fun(env:string,out:any)
---@field getdefidx fun(t:'number'?):any[]
---@field key_call fun(idx:string,fn:fun(fns:ua.confspec.fns))

---@class ua.confspec.env
---@field conf ua.config
---@field def ua.config?
---@field traceback string
---@field validate number|false
---@field envs table

---@class ua.confspec.NEEDED
local NEEDED={}

--- ;; other
---@diagnostic disable-next-line: deprecated
local islist=vim.islist or vim.tbl_islist
local function modes_with_map_to_hook(modes,map,out)
    if map=='' then return {} end
    out=out or {}
    for _,mode in ipairs(modes) do
        table.insert(out,{mode,map})
    end
    return out
end

--- ;; spec
---@type table<string,ua.confspec.spec>
local specs={
    rbool={
        __type='validate',
        __runtime=true,
        ---@param fns ua.confspec.fns
        function (fns)
            fns.assert_is_runtime('boolean')
        end
    },
    cstringfalse={
        __type='validate',
        ---@param fns ua.confspec.fns
        function (fns)
            fns.assert_is('string',{false})
        end
    },
    cnumber={
        __type='validate',
        ---@param fns ua.confspec.fns
        function (fns)
            fns.assert_is('number')
        end
    },
    mode={
        __type='separate',
        ---@param fns ua.confspec.fns
        function (fns)
            fns.assert_enum({'i','c','t','x','o','s','n','v'})
        end,
        function (_,opt)
            if opt=='v' then
                return 'x'
            end
            return opt
        end
    },
    modes={
        __type='same',
        ---@param fns ua.confspec.fns
        function (fns)
            fns.assert_is('list')
            local modes={}
            for idx in fns.foridx() do
                table.insert(modes,fns.idxmerge('mode',idx))
            end
            return modes
        end,
    },
    hooks_map={
        __type='special',
        nil,
        ---@param fns ua.confspec.fns
        function (fns,opt)
            local top=fns.get_env('top')
            if type(opt)=='string' then
                return modes_with_map_to_hook(top.map_modes,opt)
            elseif type(opt)~='table' then
            elseif #opt==1 and type(opt[1])=='string' then
                local meta={}
                for idx in fns.foridx() do
                    if fns.match({
                        p='cnumber',
                    },idx,meta) then
                    elseif idx==1 then
                    else
                        fns.error('DONTSET',idx)
                    end
                end
                local ret={}
                modes_with_map_to_hook(top.map_modes,opt[1],ret)
                for k,v in ipairs(ret) do
                    ret[k]=vim.tbl_extend('error',v,meta)
                end
                return ret
            else
                error('TODO')
            end
            error('TODO: err')
        end,
    },
    fastwarp_type={
        __type='enum',
        __enum={'normal','treesitter','fast'},
    },
    map_fastwarp={
        __type='mergef',
        __match={
            --map{{
            enable='rbool',
            map='hooks_map',
            fallback='cstringfalse',
            --}}
            type='fastwarp_type',
            rmap='hooks_map',
        },
        __fallback={
            --map{{
            enable=true,
            fallback=NEEDED,
            --}}
            type='normal',
        },
        __if={[false]={enable=false},[true]={enable=true}},
    },
    map_newline={
        __type='mergef',
        __match={
            --map{{
            enable='rbool',
            map='hooks_map',
            fallback='cstringfalse',
            --}}
        },
        __fallback={
            --map{{
            enable=true,
            fallback=NEEDED,
            --}}
        },
        __if={[false]={enable=false},[true]={enable=true}},
    },
    map_backspace={
        __type='mergef',
        __match={
            --map{{
            enable='rbool',
            map='hooks_map',
            fallback='cstringfalse',
            --}}
            overjump='rbool',
        },
        __fallback={
            --map{{
            enable=true,
            fallback=NEEDED,
            --}}
        },
        __if={[false]={enable=false},[true]={enable=true}},
    },
    map_space={
        __type='mergef',
        __match={
            --map{{
            enable='rbool',
            map='hooks_map',
            fallback='cstringfalse',
            --}}
        },
        __fallback={
            --map{{
            enable=true,
            fallback=NEEDED,
            --}}
        },
        __if={[false]={enable=false},[true]={enable=true}},
    },
    cmdtype_skip={
        __type='enum',
        __enum={'',':','>','/','?','@','-','='},
    },
    cmdtype_skips={
        __type='same',
        ---@param fns ua.confspec.fns
        function (fns)
            fns.assert_is('list')
            local out={}
            for idx in fns.foridx() do
                table.insert(out,fns.idxmerge('cmdtype_skip',idx))
            end
            return out
        end,
    },
    filter_cmdtype={
        __type='mergef',
        __match={
            --filter{{
            enable='rbool',
            --}}
            skip='cmdtype_skips',
        },
        __fallback={
            --filter{{
            enable=true,
            --}}
            skip=NEEDED,
        },
        __if={[false]={enable=false},[true]={enable=true}},
    },
    filter_alpha={
        __type='mergef',
        __match={
            --filter{{
            enable='rbool',
            --}}
            --TODO
        },
        __fallback={
            --filter{{
            enable=true,
            --}}
        },
        __if={[false]={enable=false},[true]={enable=true}},
    },
    filetype={
        __type='validate',
        ---@param fns ua.confspec.fns
        function (fns)
            fns.assert_filetype()
        end,
    },
    filetypes={
        __type='same',
        __runtime=true,
        ---@param fns ua.confspec.fns
        function (fns)
            fns.assert_is('list')
            local fts={}
            for idx in fns.foridx() do
                table.insert(fts,fns.idxmerge('filetype',idx))
            end
            return fts
        end,
    },
    filter_filetype={
        __type='mergef',
        __match={
            --filter{{
            enable='rbool',
            --}}
            treesitter='rbool',
            detect_after='rbool',
            nft='filetypes',
            --TODO
        },
        __fallback={
            --filter{{
            enable=true,
            --}}
        },
        __if={[false]={enable=false},[true]={enable=true}},
    },
    filter_tsnode={
        __type='mergef',
        __match={
            --filter{{
            enable='rbool',
            --}}
            --TODO
        },
        __fallback={
            --filter{{
            enable=true,
            --}}
        },
        __if={[false]={enable=false},[true]={enable=true}},
    },
    filter_escape={
        __type='mergef',
        __match={
            --filter{{
            enable='rbool',
            --}}
            --TODO
        },
        __fallback={
            --filter{{
            enable=true,
            --}}
        },
        __if={[false]={enable=false},[true]={enable=true}},
    },
    filter={
        __type='special_table',
        ---@param fns ua.confspec.fns
        function (fns)
            local out={
                _multi_cmdtype={},
                _multi_escape={},
                _multi_alpha={},
                _multi_filetype={},
                _multi_tsnode={},
            }
            local function is_filter(idx,map)
                return idx==map or idx:match('^'..map..'_[%d_-]*$')
            end
            for idx in fns.foridx() do
                if is_filter(idx,'cmdtype') then
                    table.insert(out._multi_cmdtype,fns.idxmerge('filter_cmdtype',idx))
                elseif is_filter(idx,'escape') then
                    table.insert(out._multi_escape,fns.idxmerge('filter_escape',idx))
                elseif is_filter(idx,'alpha') then
                    table.insert(out._multi_alpha,fns.idxmerge('filter_alpha',idx))
                elseif is_filter(idx,'filetype') then
                    table.insert(out._multi_filetype,fns.idxmerge('filter_filetype',idx))
                elseif is_filter(idx,'tsnode') then
                    table.insert(out._multi_tsnode,fns.idxmerge('filter_tsnode',idx))
                else
                    fns.error('DONTSET',idx,{
                        'cmdtype',
                        'escape',
                        'alpha',
                        'filetype',
                        'tsnode',
                    })
                end
            end
            return out
        end
    },
    integration={
        __type='mergef',
        __match={
            endwise='rbool',
        },
    },
    pair_filter_alpha={
        __type='mergef',
        __match={
            --filter{{
            enable='rbool',
            --}}
            before='rbool',
            lua_nstr='rbool',
            py_fstr='rbool',
            --TODO
        },
        __fallback={
            --filter{{
            enable=true,
            --}}
        },
    },
    pair_single={
        __type='special',
        nil,
        ---@param fns ua.confspec.fns
        ---@return ua.iconfig.pair
        function (fns,opt)
            local top=fns.get_env('top')
            local pair=fns.get_env('pair')
            local is_end=fns.get_env('pair_type')=='end'
            local function pair_to_key(opt_)
                if type(opt_)~='string' then
                    error('TODO: err')
                end
                if is_end then
                    return utils.utf8sub(opt_,1,1)
                else
                    return utils.utf8sub(opt_,-1)
                end
            end
            fns.assert_is({'string','table'})
            local old_opt=opt
            local out={
                _hooks={},
                _filters={},
            }
            if type(opt)=='string' then
                modes_with_map_to_hook(top.pair_map_modes,pair_to_key(opt),out._hooks)
                out._match=opt
                out.fallback=pair_to_key(opt)
            elseif #opt==1 then
                if type(opt[1])=='function' then
                    error('TODO: err')
                elseif type(opt[1])~='string' then
                    error('TODO: err')
                end
                modes_with_map_to_hook(top.pair_map_modes,opt[1],out._hooks)
                out._match=opt[1]
                out.fallback=pair_to_key(opt[1])
            else
                error('TODO: validate')
            end
            local function extend(c)
                c.priority=c.priority or pair.priority or 0
                c.multiline=vim.F.if_nil(c.multiline,pair.multiline,top.multiline)
                --TODO: make these things into a single functions
                -- so that all options are in one place
                return c
            end
            if type(old_opt)=='table' then
                for idx in fns.foridx() do
                    if fns.match({
                        [1]='SKIP',
                        alpha='pair_filter_alpha',
                        --TODO
                    },idx,out._filters) then
                    else
                        fns.error('DONTSET',idx,{
                            'alpha',
                            --TODO
                        })
                    end
                end
            end
            return extend(out)
        end,
    },
    pair={
        __type='special_table',
        ---@param fns ua.confspec.fns
        function (fns)
            local fout={}
            for idx in fns.foridx() do
                if fns.match({
                    [1]='SKIP',
                    [2]='SKIP',
                    nft='filetypes',
                    ft='filetypes',
                    multiline='rbool',
                    fallback='cstringfalse',
                },idx,fout) then
                else
                    fns.error('DONTSET',idx,{})
                end
            end
            fns.set_env('pair',fout)
            local out={}
            fns.set_env('pair_type','start')
            out._start_pair=fns.idxmerge('pair_single',1,NEEDED)
            fns.set_env('pair_type','end')
            out._end_pair=fns.idxmerge('pair_single',2,NEEDED)
            return out
        end,
    },
    use_filetype_getopt_entry={
        __type='validate',
        ---@param fns ua.confspec.fns
        function (fns)
            fns.assert_is('function',{false,true})
        end
    },
    use_filetype_getopt={
        __type='special',
        nil,
        ---@param fns ua.confspec.fns
        function (fns,opt)
            fns.assert_is({'table','function'},{false,true})
            if opt==true then
                return {[true]=true}
            elseif not opt then
                return {[true]=false}
            elseif type(opt)=='function' then
                return {[true]=opt}
            end
            local out={}
            for idx in fns.forallidx({}) do
                fns.key_call(idx,function(fns2)
                    fns2.assert_is('string',{true})
                    if type(idx)=='string' then fns2.assert_filetype() end
                end)
                out[idx]=fns.idxmerge('use_filetype_getopt_entry',idx)
            end
            if out[true]==nil then
                out[true]=true
            end
            return out
        end
    },
    main={
        __type='special_table',
        ---@param fns ua.confspec.fns
        function (fns)
            local out={
                _fastwarp_multi={},
                _backspace_multi={},
                _newline_multi={},
                _space_multi={},
                _pairs={},
                map_modes=fns.idxmerge('modes','map_modes',NEEDED)
            }
            fns.set_env('top',out)
            out.pair_map_modes=fns.idxmerge('modes','pair_map_modes',out.map_modes)
            local function is_map(idx,map)
                return idx==map or idx:match('^'..map..'_[%d_-]*$')
            end
            local pairs_idx={}
            for idx in fns.forallidx(fns.getdefidx()) do
                if type(idx)=='number' then
                    table.insert(pairs_idx,idx)
                elseif fns.match({
                        map_modes='SKIP', --This option is used in map configs
                        pair_map_modes='SKIP', --This option is used in pair configs
                        validate='SKIP', --This option is used outside of this file
                        multiline='rbool',
                        filter='filter',
                        integration='integration',
                        use_filetype_getopt='use_filetype_getopt',
                    },idx,out) then
                elseif is_map(idx,'space') then
                    table.insert(out._space_multi,fns.idxmerge('map_space',idx))
                elseif is_map(idx,'newline') then
                    table.insert(out._newline_multi,fns.idxmerge('map_newline',idx))
                elseif is_map(idx,'backspace') then
                    table.insert(out._backspace_multi,fns.idxmerge('map_backspace',idx))
                elseif is_map(idx,'fastwarp') or idx=='fastwarp_treesitter' or idx=='fastwarp_fast' then
                    table.insert(out._fastwarp_multi,fns.idxmerge('map_fastwarp',idx))
                else
                    fns.error('DONTSET',idx,{
                        'map_modes',
                        'pair_map_modes',
                        'multiline',
                        'filter',
                        'integration',
                        'start_pair',
                        'end_pair',
                        'override_hook',
                        'fastwarp',
                        'fastwarp_fast',
                        'fastwarp_treesitter',
                        'fastwarp_type',
                        'space',
                        'newline',
                        'backspace',
                        'change',
                        'use_filetype_getopt',
                    })
                end
            end
            for _,idx in ipairs(pairs_idx) do
                table.insert(out._pairs,fns.idxmerge('pair',idx,nil,'list'))
            end
            for _,idx in ipairs(fns.getdefidx('number')) do
                table.insert(out._pairs,fns.idxmerge('pair',idx,nil,'deflist'))
            end
            return out
        end,
    }
}

--- ;; error
---@param msg string
local function errorit(msg,possible)
    msg=msg:gsub('^ *',''):gsub('\n *','\n'):gsub('\n+$','')
    local m=vim.split(msg,'\n')
    table.insert(m,1,'')
    local top=('Configuration for the plugin \'ultimate-autopair\' is%s incorrect:'):format(possible and ' POSSIBLY' or '')
    table.insert(m,1,top)
    if possible then
        table.insert(m,1,('(If you don\'t want this error, set config validation to less that `%s`)'):format(possible))
    end
    table.insert(m,1,'')
    table.insert(m,'')
    local tab='    '
    local box_char={'|','-','+','+','+','+'}
    local styleit=function (s)
        local max_len=0
        for _,v in ipairs(s) do
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
        for i,v in ipairs(s) do
            s[i]=box_char[1]..tab..v..(' '):rep(max_len-#v)..tab..box_char[1]
        end
        table.insert(s,1,box_char[3]..line..box_char[4])
        table.insert(s,box_char[5]..line..box_char[6])
    end
    styleit(m)
    local newmsg='\n\n\n'..table.concat(m,'\n')..'\n\n'
    error(newmsg)
end
local function error_obj_to_str(obj)
    return type(obj)=='string' and ('%q'):format(obj) or tostring(obj)
end
local function error_taceback_with_val(traceback,val)
    if val then
        local v=error_obj_to_str(val)
        return ('`%s` (with the value `%s`)'):format(traceback,v)
    else
        return ('`%s`'):format(traceback)
    end
end
---@param level number
local function error_own(msg,level)
    if level==nil then level=1 end
    if level>1 then
        errorit(msg,level)
    end
    errorit(msg)
end
local function error_needed(traceback)
    errorit(([[
    The option `%s` is not set, but it should be set.
    ]]):format(traceback))
end
local function error_validate(traceback,wants_type,wants_val,val)
    assert(val~=nil)
    local valstr=error_obj_to_str(val)
    local wantstrs={}
    for _,want in ipairs(wants_val) do
        local v=error_obj_to_str(want)
        local s=('the value `%s`'):format(v)
        table.insert(wantstrs,' * '..s)
    end
    for _,want in ipairs(wants_type) do
        local s=('the type `%s`'):format(want)
        table.insert(wantstrs,' * '..s)
    end
    errorit(([[
    The option `%s` should be either
    %s
    But got the value `%s` with the type `%s`.
    ]]):format(traceback,table.concat(wantstrs,'\n'),valstr,type(val)))
end
local function error_nolist(traceback,val)
    errorit(([[
    The option %s should be a list (see `:help islist`).
    ]]):format(error_taceback_with_val(traceback,val)))
end
local function error_type(traceback,wanted_type,got_type,val)
    errorit(([[
    The option %s should be the type `%s`, but got a `%s`.
    ]]):format(error_taceback_with_val(traceback,val),wanted_type,got_type))
end
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
local function error_dontset(traceback,idx,option_names,val)
    local suggestion=''
    if option_names then
        local possible={}
        for _,optname in ipairs(option_names) do
            ---Numbers and limit from python name-error suggestion algorithm
            ---@see https://docs.python.org/3.10/whatsnew/3.10.html#nameerrors
            local limit=(#idx+#optname+3)*2/6
            if levenshtein(optname,idx)<limit then
                table.insert(possible,optname)
            end
        end
        if #possible>0 then
            suggestion=('Did you mean `%s`?'):format(table.concat(possible,'`, `'))
        end
    end
    errorit(([[
    The option %s is set, but it should not be set.

    %s
    ]]):format(error_taceback_with_val(traceback,val),suggestion))
end
local function error_enum(traceback,tbl,got)
    local v=error_obj_to_str(got)
    errorit(([[
    The option `%s` contains the value `%s`.
    However, that option should be one of `%s`.
    ]]):format(traceback,v,vim.inspect(tbl)))
end

--- ;; merge
---@param idx string|number
---@param traceback string
---@return string
local function merge_traceback(traceback,idx)
    if traceback=='' then
        return tostring(idx)
    elseif type(idx)=='string' then
        return traceback..'.'..idx
    else
        return traceback..'['..tostring(idx)..']'
    end
end
---@param old_env ua.confspec.env
---@param change 'INDEX'|'DEFAULT'|'NODEF'|'NEWOPT'|'TRACEBACK'
local function new_env(old_env,change,...)
    local envs
    if next(old_env.envs) then
        envs=setmetatable({},{__index=old_env.envs})
    else
        envs=setmetatable({},{__index=(getmetatable(old_env.envs) or {}).__index})
    end
    if change=='INDEX' then
        local idx=...
        local traceback=merge_traceback(old_env.traceback,idx)
        ---@type ua.confspec.env
        return {
            conf=old_env.conf[idx],
            def=(old_env.def or {})[idx],
            traceback=traceback,
            validate=old_env.validate,
            envs=envs,
        }
    elseif change=='TRACEBACK' then
        local idx=...
        local traceback=merge_traceback(old_env.traceback,idx)
        ---@type ua.confspec.env
        return {
            conf=old_env.conf,
            def=(old_env.def or {}),
            traceback=traceback,
            validate=old_env.validate,
            envs=envs,
        }
    elseif change=='DEFAULT' then
        ---@type ua.confspec.env
        return {
            conf=old_env.def,
            def={},
            traceback=old_env.traceback,
            validate=false,
            envs=envs,
        }
    elseif change=='NODEF' then
        ---@type ua.confspec.env
        return {
            conf=old_env.conf,
            def={},
            traceback=old_env.traceback,
            validate=old_env.validate,
            envs=envs,
        }
    elseif change=='NEWOPT' then
        local opt=...
        ---@type ua.confspec.env
        return {
            conf=opt,
            def=old_env.def,
            traceback=old_env.traceback,
            validate=old_env.validate,
            envs=envs,
        }
    else
        error('unknown env change: '..change)
    end
end
local merge
---@generic T
---@param ret T
---@param fallback string|ua.confspec.NEEDED
---@return T|ua.confspec.NEEDED
local function fallbackfn(ret,fallback)
    if ret~=nil then return ret end
    return fallback
end
--- ;;; fns
---@param env ua.confspec.env
---@return ua.confspec.fns
local function make_merge_fns(env)
    ---@type ua.confspec.fns
    local fns={} --[[@as unknown]]
    function fns.idxmerge(mergefn,idx,fallback_needed,t)
        local nenv=new_env(env,'INDEX',idx)
        if t=='list' then
            nenv=new_env(nenv,'NODEF')
        elseif t=='deflist' then
            nenv=new_env(nenv,'DEFAULT')
        end
        local ret=merge(mergefn,nenv)
        ret=fallbackfn(ret,fallback_needed)
        if ret==NEEDED then
            fns.error('NEEDED',idx)
        end
        return ret
    end
    fns.key_call=function (idx,fn)
        local nenv=new_env(env,'NODEF')
        nenv=new_env(nenv,'TRACEBACK','#key['..tostring(idx)..']')
        nenv=new_env(nenv,'NEWOPT',idx)
        return fn(make_merge_fns(nenv))
    end
    fns.foridx=function ()
        assert(type(env.conf)=='table')
        return coroutine.wrap(function ()
            for idx in pairs(env.conf) do
                coroutine.yield(idx)
            end
        end)
    end
    fns.forallidx=function (idxs)
        assert(type(env.conf)=='table')
        local keys={}
        return coroutine.wrap(function ()
            for _,k in ipairs(idxs) do
                keys[k]=true
                coroutine.yield(k)
            end
            for k in pairs(env.conf) do
                if not keys[k] then
                    coroutine.yield(k)
                end
            end
        end)
    end
    fns.match=function (tbl,idx,out,fallback_map)
        fallback_map=fallback_map or {}
        if tbl[idx]=='SKIP' then
            return true
        elseif tbl[idx] then
            out[idx]=fns.idxmerge(tbl[idx],idx,fallback_map[idx])
            return true
        end
        return false
    end
    fns.set_env=function (k,v)
        env.envs[k]=v
    end
    fns.get_env=function (k)
        return assert(env.envs[k])
    end
    fns.getdefidx=function (t)
        local ret={}
        if env.def==nil then return {} end
        for idx in pairs(env.def) do
            if type(idx)=='number' then
                if t=='number' then
                    table.insert(ret,idx)
                end
            elseif not t then
                table.insert(ret,idx)
            end
        end
        return ret
    end
    local noop=function () end
    fns.assert_is=noop
    fns.assert_enum=noop
    fns.assert_is_runtime=noop
    fns.assert_filetype=noop
    fns.error=noop
    if env.validate then
        fns.error=function (t,...)
            if t=='DONTSET' and env.validate>=1 then
                local idx,option_names=...
                if idx=='_merge' then return end
                local traceback=merge_traceback(env.traceback,idx)
                if option_names and type(idx)~='number' then
                    error_dontset(traceback,idx,option_names,env.conf[idx])
                else
                    error_dontset(traceback,nil,nil,env.conf[idx])
                end
            elseif t=='NEEDED' then
                local idx=...
                local traceback=merge_traceback(env.traceback,idx)
                error_needed(traceback)
            elseif t=='TYPE' then
                local wanted,got=...
                error_type(env.traceback,wanted,got,env.conf)
            elseif t=='ENUM' then
                local tbl,got=...
                error_enum(env.traceback,tbl,got)
            elseif t=='VTYPE' then
                local wants_type,wants_val=...
                error_validate(env.traceback,wants_type,wants_val,env.conf)
            elseif t=='NOLIST' then
                error_nolist(env.traceback,env.conf)
            else
                error('unknown error type: '..t)
            end
        end
        fns.assert_is_runtime=function (type_)
            if type(env.conf)=='function' then
                if env.validate<3 then return end
                local fn=env.conf --[[@as function]]
                local info=debug.getinfo(fn,'u')
                if info.nparams==1 then
                elseif info.nparams==0 and info.isvararg==true then
                else
                    error_own(([[
                    The option `%s` is a function which takes one and only one argument.
                    It currently takes %d arguments.
                    ]]):format(env.traceback,info.nparams),3)
                end
                return
            end
            fns.assert_is(type_)
        end
        fns.assert_is=function (type_,vals)
            if type_=='list' and type(env.conf)=='table' then
                assert(vals==nil)
                if islist(env.conf) then return end
                fns.error('NOLIST')
            elseif type(type_)=='string' and (vals==nil or #vals==0) then
                if type_=='list' then type_='table' end
                if type(env.conf)==type_ then return end
                fns.error('TYPE',type_,type(env.conf))
            elseif type(type_)=='string' then
                type_={type_}
            end
            assert((#(type_ or {})+#(vals or {}))>=2)
            for _,v in ipairs(vals or {}) do
                if env.conf==v then return end
            end
            for _,v in ipairs(type_ or {} --[[@as (string[])]]) do
                if type(env.conf)==v then return end
            end
            error_validate(env.traceback,type_,vals,env.conf)
        end
        fns.assert_enum=function (tbl)
            for _,v in ipairs(tbl) do
                if env.conf==v then
                    return
                end
            end
            fns.error('ENUM',tbl,env.conf)
        end
        fns.assert_filetype=function () fns.assert_is('string') end
        if env.validate>=3 then
            fns.assert_filetype=function ()
                fns.assert_is('string')
                local ft=env.conf
                if ft=='TelescopePrompt' then
                elseif type(ft)=='string' and vim.treesitter.language.add(vim.treesitter.language.get_lang(ft) or '') then
                else
                    local v=type(ft)=='string' and ('%q'):format(ft) or tostring(ft)
                    error_own(([[
                    The option `%s` (with the value `%s`) is not detected as a filetype.
                    ]]):format(env.traceback,v),3)
                end
            end
        end
    end
    return fns
end
---@param fns ua.confspec.fns
---@param spec ua.confspec.spec
local function mergef(fns,spec)
    assert(spec.__match)
    fns.assert_is('table',vim.tbl_keys(spec.__if or {}))
    local out={}
    local idxs=vim.tbl_keys(spec.__fallback or {})
    for idx in fns.forallidx(idxs) do
        if fns.match(spec.__match,idx,out) then
        else
            fns.error('DONTSET',idx,vim.tbl_keys(spec.__match))
        end
    end
    for idx,fallback in pairs(spec.__fallback or {}) do
        local ret=fallbackfn(out[idx],fallback)
        if ret==NEEDED then
            fns.error('NEEDED',idx)
        end
        out[idx]=ret
    end
    return out
end
---@param specname string
---@param env ua.confspec.env
---@return any
merge=function (specname,env)
    local spec=assert(specs[specname],specname)
    if env.conf==nil then
        if env.def==nil then
            return nil
        end
        local nenv=new_env(env,'DEFAULT')
        return merge(specname,nenv)
    end
    if type(env.conf)=='table' and env.conf._merge==false then
        env=new_env(env,'NODEF')
    end
    local fns=make_merge_fns(env)
    if spec.__type=='special_table' then
        assert(spec[1])
        fns.assert_is('table')
        return spec[1](fns)
    elseif spec.__type=='same' then
        assert(spec[1])
        return spec[1](fns)
    elseif spec.__type=='special' then
        --same as `same` but passed in opt
        assert(spec[2])
        return spec[2](fns,env.conf)
    elseif spec.__type=='separate' then
        assert(spec[1])
        assert(spec[2])
        if env.validate then
            spec[1](fns)
        end
        return spec[2](fns,env.conf)
    elseif spec.__type=='validate' then
        assert(spec[1])
        if env.validate then
            spec[1](fns)
        end
        return env.conf
    elseif spec.__type=='mergef' then
        if spec.__if and spec.__if[env.conf]~=nil then
            local nenv=new_env(env,'NEWOPT',spec.__if[env.conf])
            return merge(specname,nenv)
        end
        return mergef(fns,spec)
    elseif spec.__type=='enum' then
        assert(spec.__enum)
        if env.validate then
            fns.assert_enum(spec.__enum)
        end
        return env.conf
    else
        error('unknown config spec: '..spec.__type)
    end
end
---@param conf ua.config
---@param def ua.config?
---@param validate number|boolean
---@return ua.iconfig
return function (conf,def,validate)
    ---@type ua.confspec.env
    local env={
        conf=conf,
        def=def,
        traceback='',
        validate=validate==true and 1 or validate,
        envs={},
    }
    return merge('main',env)
end
