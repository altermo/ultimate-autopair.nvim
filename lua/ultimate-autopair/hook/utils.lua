local utils=require'ultimate-autopair.utils'
local hookmem=require'ultimate-autopair.hook.mem'
local M={}
M.HASH_SEP1=':'
M.HASH_SEP2=';'
M.HASH_CONF_SEP=','
M.HASH_CONF_SET='='
---@param hash ua.hook.hash
---@return {conf:table<string,string>,type:string,key:string,hash:string}
function M.get_hash_info(hash)
    local type,confstr,key=hash:match(('^(.-)%s(.-)%s(.*)$'):format(M.HASH_SEP1,M.HASH_SEP2))
    local conf={}
    for i in vim.gsplit(confstr,M.HASH_CONF_SEP) do
        local k,v=unpack(vim.split(i,M.HASH_CONF_SET))
        conf[k]=v
    end
    return {conf=conf,type=type,key=key,hash=hash}
end
---@param type string
---@param key string
---@param conf table<string,string>?
---@return ua.hook.hash
function M.to_hash(type,key,conf)
    local confstrs={}
    for k,v in vim.spairs(conf or {}) do
        table.insert(confstrs,k..M.HASH_CONF_SET..v)
    end
    return type..M.HASH_SEP1..table.concat(confstrs,M.HASH_CONF_SEP)..M.HASH_SEP2..key
end
---@return fun(ua.object):ua.info
function M.create_o_wrapper()
    local cmdtype=vim.fn.getcmdtype()
    local buf=vim.api.nvim_get_current_buf()
    local row=vim.fn.line'.'
    local col=vim.fn.col'.'
    local has_parsed={}
    local source
    ---@type ua.source
    source={
        source=buf,
        o=vim.bo[buf],
        mode=M.getmode(),
        get_parser=function ()
            local s,parser=pcall(vim.treesitter.get_parser,buf)
            if not s then return end
            if not source._cache[has_parsed] then
                parser:parse(true)
                source._cache[has_parsed]=true
            end
            return parser
        end,
        _lines=vim.api.nvim_buf_get_lines(buf,0,-1,true),
        _cache={}
    }
    if cmdtype~='' then
        row=1
        col=vim.fn.getcmdpos()
        local cmdline=vim.fn.getcmdline()
        ---@type ua.source
        source={
            source=cmdline,
            o=setmetatable({filetype='vim',buftype='prompt'},{__index=vim.bo[buf]}),
            cmdtype=cmdtype,
            mode='c',
            get_parser=function ()
                local s,parser=pcall(vim.treesitter.get_string_parser,cmdline,'vim')
                if not s then return end
                if not source._cache[has_parsed] then
                    parser:parse(true)
                    source._cache[has_parsed]=true
                end
                return parser
            end,
            _lines={cmdline},
            _cache={},
        }
    end
    local oindex=setmetatable({
        lines=source._lines,
        row=row,
        col=col,
        source=source,
    },{__index=function (t,index) return index=='line' and t.lines[t.row] or nil end })
    return function (obj)
        return setmetatable({
            m=obj,
        },{__index=oindex})
    end
end
---@param tbl ua.object[]
function M.stable_sort(tbl)
    local col={}
    for _,v in ipairs(tbl) do
        if not col[v.p or 0] then col[v.p or 0]={} end
        table.insert(col[v.p or 0],v)
    end
    local i=1
    for _,t in vim.spairs(col) do
        for _,v in ipairs(t) do
            tbl[i]=v
            i=i+1
        end
    end
end
---@param key string
---@return string
function M.activate_abbrev(key)
    if key:sub(1,1)=='\r' then
        return '\x1d'..key
    elseif vim.regex('^[^[:keyword:][:cntrl:]\x80]'):match_str(key) then
        return '\x1d'..key
    end
    return key
end
---@param hash ua.hook.hash
---@param mode string
---@param skip_index number?
---@return ua.actions
---@return ua.hook.subconf?
---@return boolean?
function M.get_act(hash,mode,skip_index)
    local info=M.get_hash_info(hash)
    local objs=hookmem[hash]
    local create_o=M.create_o_wrapper()
    for index,obj in ipairs(objs) do
        if skip_index and index<=skip_index then goto continue end
        local o=create_o(obj)
        local act=obj.run(o)
        if act then
            if mode=='i' then
                M.saveundo={act=act,row=o.row,col=o.col,buf=type(o.source.source)=='number' and o.source.source,key=info.key,index=index,hash=hash,mode=mode}
            end
            return act,obj.__hook_subconf
        end
        ::continue::
    end
    return {utils.keycode(info.key)},nil,true --TODO: be able to set default subconf (which could also be a function)
end
---@param act ua.actions
function M.generate_undo(act)
    return {}
end
---@return ua.actions
function M.undo_last_act() --TODO
    if not M.saveundo then return {} end
    local saveundo=M.saveundo
    M.saveundo=nil
    return M.generate_undo(saveundo.act)
end
---@return ua.actions
function M.last_act_cycle() --TODO
    if not M.saveundo then return {} end
    local saveundo=M.saveundo
    M.saveundo=nil
    return vim.list_extend(M.generate_undo(saveundo.act),M.get_act(saveundo.hash,saveundo.can_undo,saveundo.index))
end
---@param act ua.actions
---@param mode string
---@param conf? ua.hook.subconf
---@return string
function M.act_to_keys(act,mode,conf)
    conf=conf or {dot=true,true_dot=false,abbr=true}
    local buf=utils.new_str_buf(#act)
    for _,v in ipairs(act) do
        if type(v)=='string' then v={'ins',v} end
        if not v then
        elseif v[1]=='ins' then
            if not mode:match'[ic]' then error() end
            buf:put(v[2])
        elseif v[1]=='left' then
            buf:put(utils.key_left(v[2],conf.dot and mode=='i'))
        elseif v[1]=='right' then
            buf:put(utils.key_right(v[2],conf.dot and mode=='i'))
        elseif v[1]=='pos' then
            if conf.true_dot then
                error('Not implemented')
            else
                buf:put(utils.key_pos_nodot(v[2],v[3]))
            end
        elseif v[1]=='delete' then
            buf:put(utils.key_del(v[2],v[3]))
        end
    end
    if conf.abbr and mode:match('[ic]') then
        return M.activate_abbrev(buf:tostring())
    end
    return buf:tostring()
end
---@return string
function M.getmode()
    --TODO: what about mode()=>R should be insert mode
    return vim.fn.mode()
end
return M
