local open_pair=require'ultimate-autopair.util.open_pair'
local context=require'ultimate-autopair.util.context'
local utf=require'ultimate-autopair.util.utf'
local filter=require'ultimate-autopair.util.filter'

local M={}

---@param con ua.context
---@param conf TODO
---@return ua.actions?
function M.run(con,conf)
  for _,p in ipairs(conf.pairs) do
    if vim.startswith(context.line_before_range(con,con.cursor_range),utf.raw(p[1])) then
      return {{'delete',1,utf.len(p[2])}}
    end
  end
end

return M
