local filter=require'ultimate-autopair.filter'
local M={}

---@class ua.filter.multi.conf
---@field once ua.filter[]
---@field on_iter ua.filter[]

---@type ua.filter_fn<ua.filter.multi.conf>
M['or']=function(con,range,conf)
  for _,f in ipairs(conf) do
    if filter.run_pos(f,con,range) then
      return true
    end
  end
  return false
end

---@type ua.filter_fn<ua.filter.multi.conf>
M['and']=function(con,range,conf)
  for _,f in ipairs(conf) do
    if not filter.run_pos(f,con,range) then
      return false
    end
  end
  return true
end

return M
