local M={}

---@param filter ua.filter?
---@param con ua.context
---@param range Range4
---@return boolean
function M.run_pos(filter,con,range)
  if not filter then
    return false
  end

  return filter[1](con,range,filter[2])
end

return M
