---@class prof.map.module:core.module
---@field mode string[]
---@field lhs string
---@field rhs string
---@class prof.map.opt:prof.mconf
---@field [1] string|string[]
---@field [2] string
---@field [3] string

local core=require'ultimate-autopair.core'
local M={}
---@param m prof.map.module
---@return core.get_map-fn
function M.get_map_wrapp(m)
    return function (mode)
        if vim.tbl_contains(m.mode,mode) then
            return {m.lhs}
        end
    end
end
---@param m prof.map.module
---@return core.check-fn
function M.check_wrapp(m)
    return function (o)
        if o.key~=m.lhs then return end
        if not m.filter(o) then return end
        if type(m.rhs)=='function' then
            return m.rhs(o,m)
        end
        return m.rhs
    end
end
---@param opts prof.map.opt
---@param mconf prof.mconf
---@return core.module
function M.create_map(opts,mconf)
    local m={}
    m.p=opts.p or mconf.p or 10
    m.mode=type(opts[1])=='string' and {opts[1]} or opts[1] --[[@as string[] ]]
    for _,v in ipairs(m.mode) do
        if not vim.tbl_contains(core.modes,v) then
            error(('core.modes `%s` does not contain mode %s'):format(core.modes,v))
        end
    end
    m.lhs=opts[2]
    if #m.lhs~=1 then
        error(('lhs in `%s` must be of length 1'):format(opts))
    end
    m.rhs=opts[3]
    m.conf=opts
    m.filter=function () return true end
    m.get_map=M.get_map_wrapp(m)
    m.check=M.check_wrapp(m)
    return m
end
---@param conf prof.mconf
---@param mem core.module[]
function M.init(conf,mem)
    for _,v in ipairs(conf) do
        table.insert(mem,M.create_map(v,conf))
    end
end
return M
