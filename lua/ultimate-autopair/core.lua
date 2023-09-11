--Internal
---@class core.o
---@field key string --C
---@field line string --D*
---@field lines string[] --C
---@field col number --*
---@field row number --*
---@field _offset fun(row:number):number --C
---@field _deoffset fun(row:number):number --C
---@field _coloffset fun(col:number,row:number):number --C
---@field _decoloffset fun(col:number,row:number):number --C
---@field incmd boolean --C
---@field mode string
---@field save table --S*
---@field inoinit boolean? --C
---@class core.module
---@field get_map? core.get_map-fn
---@field oinit? core.oinit-fn
---@field check? core.check-fn
---@field doc? string
---@field sort? core.sort-fn
---@field filter? core.filter-fn
---@field p number
---@alias core.get_map-fn fun(mod:string):string[]?
---@alias core.check-fn fun(o:core.o):string?
---@alias core.filter-fn fun(o:core.o):boolean?
---@alias core.oinit-fn fun(delete:boolean?)
---@alias core.sort-fn fun(a:core.module,b:core.module):boolean?
---@alias core.act ({[1]:("home"|"end"|"delete"|"l"|"h"|"k"|"j"|"newline"),[number]:any}|string)[]

local debug=require'ultimate-autopair.debug'
local utils=require'ultimate-autopair.utils'
local M={}
---@type core.module[]
M.mem={}
---@type table<string,table<string,table|false>>
M.map={}
M.modes={'i','c'}
M.dont_map={}
M.funcs={}
M.I={}
---@param mode string
---@return table<string,table>
function M.I.get_maps(mode)
    local maps=vim.api.nvim_get_keymap(mode)
    local ret={}
    for _,keyinfo in ipairs(maps) do
        ret[keyinfo.lhs]=keyinfo
    end
    return ret
end
---@param key string
---@return string
function M.I.activate_iabbrev(key)
    if key:sub(1,1)=='\r' then
        return '\x1d'..key
    elseif vim.regex('[^[:keyword:][:cntrl:]\x80]'):match_str(key:sub(1,1)) then
        return '\x1d'..key
    end
    return key
end
---@param key string
---@return core.o
function M.get_o_value(key)
    local line=utils.getline()
    local row,lines=utils.getlines()
    local col=utils.getcol()
    local linenr=utils.getlinenr()
    local incmd=utils.incmd()
    return {
        key=key,
        line=line,
        lines=lines,
        col=col,
        row=row,
        _offset=function(_) return linenr-row end,
        _deoffset=function(_) return row-linenr end,
        _coloffset=function (_) return 0 end,
        _decoloffset=function (_) return 0 end,
        incmd=incmd,
        save={},
        mode=utils.getmode(),
    }
end
---@param key string
---@return string
function M.run(key)
    if M.disable then
        return M.I.activate_iabbrev(key)
    end
    local o=M.get_o_value(key)
    for _,v in ipairs(M.mem) do
        if v.check then
            ---@type string?
            local ret=debug.run(v.check,{info=v,args={vim.deepcopy(o)}})
            if ret then
                if o.mode=='c' or o.mode=='i' then return M.I.activate_iabbrev(ret) end
                return ret
            end
        end
    end
    if o.mode=='c' or o.mode=='i' then
        return M.I.activate_iabbrev(key)
    end
    return key
end
---@param key string
---@return function
function M.get_run(key)
    if not M.funcs[key] then
        M.funcs[key]=function ()
            return M.run(key)
        end
    end
    return M.funcs[key]
end
---@param mode string
function M.delete_mem_map(mode)
    local mapps=M.I.get_maps(mode)
    for key,old_map in pairs(M.map[mode] or {}) do
        if mapps[key] and M.funcs[key] and
            mapps[key].callback==M.funcs[key] then
            vim.keymap.del(mode,key,{})
            if old_map then vim.fn.mapset(mode,false,old_map) end
        end
    end
end
function M.clear()
    vim.api.nvim_create_augroup('UltimateAutopair',{clear=true})
    M.init_mem_oinits(true)
    for _,mode in ipairs(M.modes) do
        M.delete_mem_map(mode)
    end
    M.mem={}
    M.map={}
end
---@param mem core.module[]
function M.sort_mem(mem)
    table.sort(mem,function(a,b)
        if a.p~=b.p then
            return a.p>b.p
        end
        if a.sort then
            local bool=a.sort(a,b)
            if bool~=nil then return bool end
        end
        if b.sort then
            local bool=b.sort(a,b)
            if bool~=nil then return bool end
        end
        return false
    end)
end
---@param mode string
---@return table<string,table>
function M.get_mem_maps(mode)
    local mapped=vim.defaulttable()
    for _,v in ipairs(M.mem) do
        if v.get_map then
            for _,key in ipairs(v.get_map(mode) or {}) do
                table.insert(mapped[key].desc,v.doc)
            end
        end
    end
    return mapped
end
---@param deinit? boolean
function M.init_mem_oinits(deinit)
    for _,v in ipairs(M.mem) do
        if v.oinit then v.oinit(deinit) end
    end
end
---@param mapped table<string,table>
---@param mode string
function M.init_mapped(mapped,mode)
    local mapps=M.I.get_maps(mode)
    M.map[mode]={}
    for key,opts in pairs(mapped) do
        local mapkey=utils.keycode(key)
        if not vim.tbl_contains(M.dont_map,mapkey) then
            M.map[mode][mapkey]=mapps[mapkey] or false
            vim.keymap.set(mode,key,M.get_run(mapkey),{noremap=true,expr=true,desc=vim.fn.join(opts.desc,'\n\t\t '),replace_keycodes=false})
        end
    end
end
function M.init()
    vim.api.nvim_create_augroup('UltimateAutopair',{clear=false})
    M.sort_mem(M.mem)
    for _,mode in ipairs(M.modes) do
        local mapped=M.get_mem_maps(mode)
        M.init_mapped(mapped,mode)
    end
    M.init_mem_oinits()
end
return M
