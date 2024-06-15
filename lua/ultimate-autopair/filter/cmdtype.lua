local M={}
local utils=require'ultimate-autopair.utils'
---@param o ua.filter
---@return boolean?
function M.call(o)
    if not o.conf.skip then return true end
    if o.source.mode~='c' then return true end
    return not utils.in_list(o.conf.skip,o.source.o.cmdtype)
end
M.clear_cache={
}
return M
