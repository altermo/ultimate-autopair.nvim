---I
---@class ext.cmdtype.conf:prof.def.ext.conf
---@field skip string[]
---@class ext.cmdtype.pconf
---@field skipcmdtype? string[]

local M={}
local utils=require'ultimate-autopair.utils'
---@param m prof.def.module
---@param ext prof.def.ext
---@return boolean?
function M.filter(m,ext)
    local conf=ext.conf
    ---@cast conf ext.cmdtype.conf
    ---@type ext.cmdtype.pconf
    local pconf=m.conf
    local cmdtype=utils.getcmdtype()
    if vim.tbl_contains(conf.skip,cmdtype) then
        return
    elseif pconf.skipcmdtype and vim.tbl_contains(pconf.skipcmdtype,cmdtype) then
        return
    end
    return true
end
---@param m prof.def.module
---@param ext prof.def.ext
function M.call(m,ext)
    local filter=m.filter
    m.filter=function(o)
        if M.filter(m,ext) then
            return filter(o)
        end
    end
    local check=m.check
    m.check=function(o)
        if M.filter(m,ext) then
            return check(o)
        end
    end
end
return M
