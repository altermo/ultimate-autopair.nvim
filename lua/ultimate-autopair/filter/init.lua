local filter=require'ultimate-autopair.util.filter'

---@class ua.filter.multi.conf
---@field once ua.filter[]
---@field on_iter ua.filter[]

---@type ua.filter_fn<ua.filter.multi.conf>
local multi_or=function(con,range,conf)
  for _,f in ipairs(conf) do
    if filter.run_pos(f,con,range) then
      return true
    end
  end
  return false
end

---@type ua.filter_fn<ua.filter.multi.conf>
local multi_and=function(con,range,conf)
  for _,f in ipairs(conf) do
    if not filter.run_pos(f,con,range) then
      return false
    end
  end
  return true
end

return {
  multi_and=multi_and,
  multi_or=multi_or,
}
