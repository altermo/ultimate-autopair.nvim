local M={}
local utils=require'ultimate-autopair.utils'
---@param o ua.filter
---@return boolean?
function M.call(o)
    if not o.conf.skip then return true end
    if o.source.mode~='c' then return true end
    return not vim.tbl_contains(o.conf.skip,o.source.cmdtype)
end
M.conf={
    skip='string[]',
}
return M
