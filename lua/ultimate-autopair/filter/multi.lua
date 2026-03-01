---@param conf TODO
---@return ua.filter
return function(conf)
  return {
    iter_pos=function(...)
      for _,fn in ipairs(conf.iter_pos) do
        if fn(...) then
          return true
        end
      end
      return false
    end,
    once=function(...)
      for _,fn in ipairs(conf.once) do
        if fn(...) then
          return true
        end
      end
      return false
    end,
  }
end
