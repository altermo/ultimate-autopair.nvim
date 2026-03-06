local M={}

---@param filter ua.filter?
---@param con ua.context
function M.run_once(filter,con)
  if not filter or not filter[1].once then
    return true
  end

  if filter[1].once=='iter_pos' then
    return M.run_iter_pos(filter,con,con.cursor_range)
  end

  return filter[1].once(con,filter[2])
end

---@param filter ua.filter?
---@param con ua.context
---@param range Range4
function M.run_iter_pos(filter,con,range)
  if not filter or not filter[1].iter_pos then
    return true
  end

  return filter[1].iter_pos(con,range,filter[2])
end

return M
