---I
local M={}
local utils=require'ultimate-autopair.utils'
---@param m prof.def.module
---@param ext prof.def.ext
function M.call(m,ext)
    local filter=m.filter
    m.filter=function(o)
        local cmdtype=utils.getcmdtype()
        if vim.tbl_contains(ext.conf.skip,cmdtype) then
            return
        elseif m.conf.skipcmdtype and vim.tbl_contains(m.conf.skipcmdtype,cmdtype) then
            return
        end
        return filter(o)
    end
end
return M
