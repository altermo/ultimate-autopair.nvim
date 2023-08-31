---I
---@class ext.cmdtype.conf:prof.def.ext.conf
---@field skip string[]|fun(...:prof.def.optfn):string[]
---@class ext.cmdtype.pconf
---@field skipcmdtype? string[]|fun(...:prof.def.optfn):string[]?

local M={}
local utils=require'ultimate-autopair.utils'
local default=require'ultimate-autopair.profile.default.utils'
---@param m prof.def.module
---@param ext prof.def.ext
---@param o core.o
---@param incheck boolean?
---@return boolean?
function M.filter(m,ext,o,incheck)
    local conf=ext.conf
    ---@cast conf ext.cmdtype.conf
    ---@type ext.cmdtype.pconf
    local pconf=m.conf
    local cmdtype=utils.getcmdtype()
    if vim.tbl_contains(default.orof(conf.skip,o,m,incheck),cmdtype) then
        return
    elseif vim.tbl_contains(default.orof(pconf.skipcmdtype,o,m,incheck) or {},cmdtype) then
        return
    end
    return true
end
---@param m prof.def.module
---@param ext prof.def.ext
function M.call(m,ext)
    local filter=m.filter
    m.filter=function(o)
        if M.filter(m,ext,o) then
            return filter(o)
        end
    end
    local check=m.check
    m.check=function(o)
        if M.filter(m,ext,o,true) then
            return check(o)
        end
    end
end
return M
