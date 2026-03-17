local M={}

local filter_map

---@param filter ua.filter?
---@param con ua.context
---@param range Range4
---@return boolean
function M.run_pos(filter,con,range)
  if not filter_map then
    filter_map={
      ['or']=require'ultimate-autopair.filter.multi'['or'],
      ['and']=require'ultimate-autopair.filter.multi'['and'],
      alpha=require'ultimate-autopair.filter.alpha',
      escape=require'ultimate-autopair.filter.escape',
      cmdtype=require'ultimate-autopair.filter.cmdtype',
    }
  end

  if not filter then
    return false
  end

  return (filter_map[filter[1]] or filter[1])(con,range,filter[2])
end

return M
