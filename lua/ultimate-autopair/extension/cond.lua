---FI
local M={}
local utils=require'ultimate-autopair.utils'
local default=require'ultimate-autopair.profile.default.utils'
---@type fun(opt:table,...)[]
M.fns={
    in_macro=function ()
        return vim.fn.reg_recording()~='' or vim.fn.reg_executing()~=''
    end,
    in_string=function (opt,col,row)
        local new_o=utils._get_o_pos(opt.o,col,row)
        local tsnode=require'ultimate-autopair.extension.tsnode'
        return tsnode._in_tsnode(new_o,{'string','raw_string'})
    end,
    in_check=function (opt)
        return opt.incheck
    end,
    in_cmdline=function (opt)
        return opt.o.incmd
    end,
    in_lisp=function (opt,col,row,notree)
        if notree then return vim.o.lisp end
        local new_o=utils._get_o_pos(opt.o,col,row)
        local ft=utils.getsmartft(new_o)
        return vim.filetype.get_option(ft,'lisp')
    end,
    is_pair=function (opt)
        return default.get_type_opt(opt.m,'pair')
    end,
    is_start_pair=function (opt)
        return default.get_type_opt(opt.m,'start')
    end,
    is_end_pair=function (opt)
        return default.get_type_opt(opt.m,'end')
    end,
    is_ambiguous_pair=function (opt)
        return default.get_type_opt(opt.m,'ambiguous')
    end,
    get_tsnode=function (opt,col,row)
        local new_o=utils._get_o_pos(opt.o,col,row)
        return utils.gettsnode(new_o)
    end,
    get_tsnode_type=function (opt,col,row)
        local new_o=utils._get_o_pos(opt.o,col,row)
        local node=utils.gettsnode(new_o)
        return not node or node:type()
    end,
    get_ft=function (opt,col,row,notree)
        local new_o=utils._get_o_pos(opt.o,col,row)
        return utils.getsmartft(new_o,notree)
    end,
    get_mode=function (_,complex)
        return utils.getmode(complex)
    end,
    get_cmdtype=function ()
        return utils.getcmdtype()
    end,
}
---@param opt table
---@return function[]
function M.init_fns(opt)
    return vim.tbl_map(function(fn)
        return function (...) return fn(opt,...) end
    end,M.fns)
end
---@param conds fun(fn:function[],o:core.o,m:prof.def.module)[]|fun(fn:function[],o:core.o,m:prof.def.module)?
---@param m prof.def.module
---@param o core.o
---@param incheck boolean?
---@return boolean
function M.cond(conds,o,m,incheck)
    ---@cast conds table
    local fns=M.init_fns({o=o,m=m,incheck=incheck})
    for _,v in ipairs(type(conds)=='function' and {conds} or conds or {}) do
        if not v(fns,o,m) then
            return false
        end
    end
    return true
end
---@param m prof.def.module
---@param ext prof.def.ext
function M.call(m,ext)
    local conf=ext.conf
    local check=m.check
    local cond=m.conf.cond
    m.check=function(o)
        if cond and not M.cond(cond,o,m,true) then
            return
        end
        if conf.cond and not M.cond(conf.cond,o,m,true) then
            return
        end
        return check(o)
    end
    if not conf.filter then return end
    local filter=m.filter
    m.filter=function(o)
        if cond and not M.cond(cond,o,m) then
            return
        end
        if conf.cond and not M.cond(conf.cond,o,m) then
            return
        end
        return filter(o)
    end
end
return M
