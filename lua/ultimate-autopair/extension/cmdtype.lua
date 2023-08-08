---I
local M={}
local utils=require'ultimate-autopair.utils'
---@param m prof.def.module
---@param ext prof.def.ext
---@return boolean?
function M.filter(m,ext)
    local cmdtype=utils.getcmdtype()
    if vim.tbl_contains(ext.conf.skip,cmdtype) then
        return
    elseif m.conf.skipcmdtype and vim.tbl_contains(m.conf.skipcmdtype,cmdtype) then
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
