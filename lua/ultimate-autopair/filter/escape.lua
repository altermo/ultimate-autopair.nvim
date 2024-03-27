local M={}
local utils=require'ultimate-autopair.utils'
---@param o ua.filter
---@return boolean?
function M.call(o)
    local col=o.cols-1
    local escape=false
    local escapechar=o.conf.escapechar or '\\'
    while utils.get_char(o.line,col)==escapechar do
        col=col-1+vim.str_utf_start(o.line,col)
        escape=not escape
    end
    return not escape
end
M.conf={
    escapechar='string?'
}
return M
