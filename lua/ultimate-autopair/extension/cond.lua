---FI
---@class ext.cond.conf:prof.def.ext.conf
---@field cond? ext.cond.fn|ext.cond.fn[]
---@field filter? boolean|fun(...:prof.def.optfn):boolean?
---@class ext.cond.pconf
---@field cond? ext.cond.fn|ext.cond.fn[]
---@alias ext.cond.opt {o:core.o,m:prof.def.module,incheck:boolean?}
---@alias ext.cond.fn fun(fn:function[],o:core.o,m:prof.def.module)

local M={}
local utils=require'ultimate-autopair.utils'
local default=require'ultimate-autopair.profile.default.utils'
---@type fun(opt:ext.cond.opt,...)[]
M.fns={
    in_macro=function ()
        return vim.fn.reg_recording()~='' or vim.fn.reg_executing()~=''
    end,
    in_string=function (opt,col,row)
        local new_o=utils._get_o_pos(opt.o,col,row)
        local tsnode=require'ultimate-autopair.extension.tsnode'
        local node=tsnode._in_tsnode(new_o,{'string','raw_string'},opt.incheck,opt.m)
        return node and node:parent()
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
        return utils.ft_get_option(ft,'lisp')
    end,
    in_node=function (opt,nodes,col,row)
        local new_o=utils._get_o_pos(opt.o,col,row)
        local tsnode=require'ultimate-autopair.extension.tsnode'
        local node=tsnode._in_tsnode(new_o,type(nodes)=='string' and {nodes} or nodes,opt.incheck,opt.m)
        return node and node:parent() and node or nil
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
---@param opt ext.cond.opt
---@return function[]
function M.init_fns(opt)
    return vim.tbl_map(function(fn)
        return function (...) return fn(opt,...) end
    end,M.fns)
end
---@param conds? ext.cond.fn|ext.cond.fn[]
---@param m prof.def.module
---@param o core.o
---@param incheck boolean?
---@return boolean
function M.cond(conds,o,m,incheck)
    local fns=M.init_fns({o=o,m=m,incheck=incheck})
    ---@cast conds ext.cond.fn[]
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
    ---@cast conf ext.cond.conf
    local check=m.check
    ---@type ext.cond.pconf
    local pconf=m.conf
    local cond=pconf.cond
    m.check=function(o)
        if cond and not M.cond(cond,o,m,true) then
            return
        end
        if conf.cond and not M.cond(conf.cond,o,m,true) then
            return
        end
        return check(o)
    end
    if type(conf.filter)~='function' and not conf.filter then return end
    local filter=m.filter
    m.filter=function(o)
        if type(conf.filter)=='function' and not conf.filter(o,m,false) then
            return filter(o)
        end
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
