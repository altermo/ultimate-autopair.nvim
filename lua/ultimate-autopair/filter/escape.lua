local M={}
local utils=require'ultimate-autopair.utils'
---@param o ua.filter
---@return boolean?
function M.call(o)
    local col=o.cols-1
    local escape=false
    local escapechar=o.conf.escapechar or '\\'
    while utils.get_char(o.lines[o.rows],col)==escapechar do
        col=col-1+vim.str_utf_start(o.lines[o.rows],col)
        escape=not escape
    end
    return not escape
end
M.clear_cache={
    'textchange',
}
return M
