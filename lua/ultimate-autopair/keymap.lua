local pair=require'ultimate-autopair.pair'
local utils=require'ultimate-autopair.utils'
local M={}

local maps_module={
    backspace=require'ultimate-autopair.map.backspace',
}

---@class ua.keymap.info
--- TODO (maybe?): instead of this, just have a [function, config] tuple
---@field [number] [number|string,boolean|any]
---@field fallback string|true|fun():string

---@class ua.keymap.map.entry
---@field p number priority
---@field a [number|string,boolean|any] action
---@field d string desc

---@class ua.keymap.map.list
---@field [number] ua.keymap.map.entry
---@field fallback string|true|fun():string

---@alias ua.keymap.map.table table<ua.mode,table<string,ua.keymap.map.list>>

---@type table<ua.mode,table<string,ua.keymap.info>>
local _mapped=vim.defaulttable(function () return vim.defaulttable(function () return {} end) end)
---@type ua.iconfig?
local _used_iconfig=nil

local function clear_mapped()
    for mode,maps in pairs(_mapped) do
        for key in pairs(maps) do
            if vim.startswith(vim.fn.maparg(key,mode),"v:lua.require'ultimate-autopair.keymap") then
                vim.keymap.del(mode,key)
            end
        end
    end
    _mapped=vim.defaulttable(function () return vim.defaulttable(function () return {} end) end)
    _used_iconfig=nil
end

---@param tbl ua.keymap.map.table
---@param hooks ua.iconfig.hook[]
---@param desc string
---@param action any[]
local function add_hooks_to(tbl,hooks,desc,action)
    for _,v in ipairs(hooks) do
        table.insert(tbl[v.mode][vim.fn.keytrans(utils.keycode(v[1]))],{
            p=v.priority,
            a=action,
            d=desc,
        })
    end
end

---@param tbl ua.keymap.map.table
---@param maps ua.iconfig.map.root[]
---@param name string
local function add_map_hooks_to(tbl,maps,name)
    for id,map in pairs(maps) do
        add_hooks_to(tbl,map.hooks,('autopairs map %s'):format(name),{name,id})
    end
end

---@param tbl ua.keymap.map.table
---@param pairs_ ua.iconfig.pair[]
local function add_pair_hooks_to(tbl,pairs_)
    ---@type table<number,([ua.iconfig.hook[],string,any[]])[]>
    local len_to_pair=vim.defaulttable(function () return {} end)
    local function fn(pair_,...)
        local len=-(type(pair_)=='function' and math.huge or #pair_)
        table.insert(len_to_pair[len],{...})
    end
    for id,pair_ in ipairs(pairs_) do
        local desc=('autopairs pair %s,%s')
            :format(tostring(pair_.start_pair.pair),tostring(pair_.end_pair.pair))

        fn(pair_.end_pair.pair,pair_.end_pair.hooks,desc,{id,true})
        fn(pair_.start_pair.pair,pair_.start_pair.hooks,desc,{id,false})
    end
    for _,pairs_info in vim.spairs(len_to_pair) do
        for _,pair_info in ipairs(pairs_info) do
            add_hooks_to(tbl,unpack(pair_info))
        end
    end
end

---@param tbl ua.keymap.map.table
---@param fallback ua.config.fallback
local function add_fallback_to_hooks(tbl,fallback)
    for mode,maps in pairs(tbl) do
        for key,list in pairs(maps) do
            local fall=fallback[key] or fallback[true] or ''
            if type(fall)=='table' then
                list.fallback=fall[mode] or fall[true] or ''
            else
                ---@cast fall -ua.config.fallback.entry
                list.fallback=fall
            end
        end
    end
end

---@param tbl ua.keymap.map.table
local function apply_map_from(tbl)
    for mode,maps in pairs(tbl) do
        for key,list in pairs(maps) do
            if key:find'\0' then
                error('Null byte found in keymap lhs, mapping this crashes neovim')
            end

            local actions=_mapped[mode][key]

            actions.fallback=list.fallback

            local desc={}
            for _,entry in ipairs(list) do
                table.insert(desc,entry.d)
                table.insert(actions,entry.a)
            end

            vim.keymap.set(mode=='v' and 'x' or mode,
                key,
                ("v:lua.require'ultimate-autopair.keymap'._run(%q,%q)"):format(mode,vim.fn.keytrans(key)),
                {noremap=true,
                    expr=true,replace_keycodes=false,
                    desc=table.concat(desc,'\n\t\t ')})
        end
        setmetatable(_mapped[mode],nil)
    end
    setmetatable(_mapped,nil)
end

---@param tbl ua.keymap.map.table
local function stable_sort(tbl)
    local function sort(list)
        local col=vim.defaulttable(function () return {} end)
        for _,v in ipairs(list) do
            table.insert(col[-v.p],v)
        end
        if not next(col,next(col)) then return end
        local i=1
        for _,t in vim.spairs(col) do
            table.move(t,1,#t,i,list)
            i=i+#t
        end
    end
    for _,v in pairs(tbl) do
        vim.tbl_map(sort,v)
    end
end

---@param iconf ua.iconfig
function M.set_mappings(iconf)
    clear_mapped()

    local tbl=vim.defaulttable(function () return vim.defaulttable(function () return {} end) end)

    add_map_hooks_to(tbl,iconf.backspace,'backspace')
    -- add_map_hooks_to(tbl,iconf.newline,'newline')
    -- add_map_hooks_to(tbl,iconf.space,'space')

    add_pair_hooks_to(tbl,iconf.pairs)

    add_fallback_to_hooks(tbl,iconf.fallback)

    stable_sort(tbl)

    apply_map_from(tbl)

    _used_iconfig=iconf
end

local keys={
    key_bs=vim.keycode'<bs>',
    key_del=vim.keycode'<del>',
    key_left=vim.keycode'<left>',
    key_right=vim.keycode'<right>',
    key_end=vim.keycode'<end>',
    key_home=vim.keycode'<home>',
    key_up=vim.keycode'<up>',
    key_down=vim.keycode'<down>',
    key_noundo=vim.keycode'<C-g>U',
    key_i_ctrl_o=vim.keycode'<C-\\><C-o>',
}

---@param row number
---@param col number
---@return string
local function key_pos_nodot(row,col)
    --TODO: make it dot complaint

    local mode=vim.fn.mode()
    if mode=='i' or mode=='R' then
        -- key_i_ctrl_o is important because otherwise things break internally (like undo)
        return keys.key_i_ctrl_o..utils.keycode(('<cmd>call cursor(%s,%s)\r'):format(row,col ))
    elseif mode=='c' then
        assert(row==nil or row==1)
        return keys.key_home..keys.key_right:rep(vim.api.nvim_strwidth(vim.fn.getcmdline():sub(1,col-1)))
    else
        return utils.keycode(('<cmd>call cursor(%s,%s)\r'):format(row or '"."',col))
    end
end
---@param action ua.actions
---@return string
local function action_to_keys(action)
    --TODO: the whole action system is pretty jank: how to make it not jank...

    local out={}
    local mode=vim.fn.mode()
    local key_left,key_right
    local orig=vim.api.nvim_win_get_cursor(0)
    if mode=='c' then
        orig={1,vim.fn.getcmdpos()-1}
    end
    if mode=='i' or mode=='R' then
        key_left=keys.key_noundo..keys.key_left
        key_right=keys.key_noundo..keys.key_right
    else
        key_left=keys.key_left
        key_right=keys.key_right
    end
    for _,act in ipairs(action) do
        if type(act)=='string' then
            table.insert(out,act)
        elseif act[1]=='h' then
            table.insert(out,key_left:rep(vim.api.nvim_strwidth(act[2])))
        elseif act[1]=='l' then
            table.insert(out,key_right:rep(vim.api.nvim_strwidth(act[2])))
        elseif act[1]=='delete' then
            if act[2] then
                table.insert(out,keys.key_bs:rep(vim.api.nvim_strwidth(act[2])))
            end
            if act[3] then
                table.insert(out,keys.key_del:rep(vim.api.nvim_strwidth(act[3])))
            end
        elseif act[1]=='pos' then
            table.insert(out,key_pos_nodot(act[2],act[3]))
        elseif act[1]=='orig' then
            table.insert(out,key_pos_nodot(orig[1],orig[2]+1))
        else
            error('TODO')
        end
    end
    return table.concat(out,'')
end

---@param mode ua.mode
---@param key string
---@return string
local function run(mode,key)
    ---@type ua.keymap.info
    local actions=_mapped[mode][key]
    assert(actions)

    assert(_used_iconfig)

    local con=utils.create_context(_used_iconfig)
    for _,action in ipairs(actions) do
        local ret
        local path1,path2=unpack(action)
        if type(path1)=='number' then
            assert(type(path2)=='boolean')
            if path2 then
                ret=pair.run_end(assert(_used_iconfig.pairs[path1]),con)
            else
                ret=pair.run_start(assert(_used_iconfig.pairs[path1]),con)
            end
        else
            assert(type(path1)=='string')
            ret=assert(maps_module[path1]).run(
                assert(_used_iconfig[path1][path2]),
                _used_iconfig.pairs,path2,con)
        end
        if ret then
            return action_to_keys(ret)
        end
    end

    return type(actions.fallback)=='function' and actions.fallback()
        or actions.fallback==true and utils.keycode(key)
        or assert(actions.fallback --[[@as string]])
end

---@param str string
local function add_abbrev_expand(str)
    if str:sub(1,1)=='\r' then
        return '\x1d'..str
    elseif vim.regex('^[^[:keyword:][:cntrl:]\x80]'):match_str(str) then
        return '\x1d'..str
    end
    return str
end

function M._run(...)
    local errmsg
    local _,ret=xpcall(run,function (msg) errmsg=debug.traceback(msg,2) end,...)
    if errmsg then
        return utils.keycode((('<cmd>lua error(%q,0)\r'):format(errmsg))
            :gsub('\n','n'))
    end
    return add_abbrev_expand(ret)
end

return M
