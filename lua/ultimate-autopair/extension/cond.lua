---FI
local M={}
local utils=require'ultimate-autopair.utils'
---@type fun(o:core.o,m:prof.def.module)[]
M.fns={
    in_macro=function ()
        return vim.fn.reg_recording()~='' or vim.fn.reg_executing()~=''
    end,
    in_string=function (o,_,col,row,conf)
        local new_o=utils._get_o_pos(o,col,row)
        local str=require'ultimate-autopair.extension.string'
        str.instring(new_o,conf or {tsnode={'string','raw_string'}})
    end,
    get_tsnode=function (o,_,col,row)
        local new_o=utils._get_o_pos(o,col,row)
        return utils.gettsnode(new_o)
    end,
}
M.fn={
    preset={
        --initializes and takes no arg, like default.init_fns
        in_macro=function () end,
        get_tsnode=function () end,
        in_string=function () end,
        in_check=function () end,
        is_start_pair=function () end,
        is_ambigous_pair=function () end,
        is_pair=function () end,
        is_end_pair=function () end,
        get_node=function () end,
        get_module_type=function() end,
        get_filetype=function () end,
    },
    utils={
        getmode=utils.getmode,
        getsmartft=utils.getsmartft,
        getcmdtype=utils.getcmdtype,
    },
    _utils={
        _gettsnode=utils.gettsnode,
        _getlinenr=utils.getlinenr,
        _getcol=utils.getcol,
        _getline=utils.getline,
        _getlines=utils._getlines,
        _getlinecount=utils._getlinecount,
        _get_o_pos=utils._get_o_pos,
        _filter_pos=utils._filter_pos,
    },
    ---@param o core.o
    o=function (o) return o end,
}
---@param m prof.def.module
---@param o core.o
---@return function[]
function M.init_fns(o,m)
    return vim.tbl_map(function(fn)
        return function (...) fn(o,m,...) end
    end,M.fns)
end
---@param conds fun(fn:function[],o:core.o,m:prof.def.module)[]
---@param m prof.def.module
---@param o core.o
---@return boolean?
function M.cond(conds,o,m)
    local fns=M.init_fns(o,m)
    for _,v in ipairs(conds) do
        v(fns,o,m)
    end
end
---@param m prof.def.module
---@param ext prof.def.ext
function M.call(m,ext)
    local conf=ext.conf
    local check=m.check
    local cond=type(m.conf.cond)=='function' and {m.conf.cond} or m.conf.cond
    m.check=function(o)
        if cond and not M.cond(cond,o,m) then
            return
        end
        if conf.cond and not M.cond(conf.cond,o,m) then
            return
        end
        return check(o)
    end
    local filter=m.filter
    m.filter=function(o)
        if not M.cond(cond,m,o) then
            return
        end
        if conf.cond and not M.cond(conf.cond,m,o) then
            return
        end
        return filter(o)
    end
end
return M
