local filter=require'util.filter'

---@class ua.filter.multi.conf
---@field once ua.filter[]
---@field on_iter ua.filter[]

---@type ua.ifilter<ua.filter.multi.conf>
local multi_or={
  once=function(con,conf)
    for _,f in ipairs(conf.once or {}) do
      if filter.run_once(f,con) then
        return true
      end
    end
    return false
  end,
  iter_pos=function(con,range,conf)
    for _,f in ipairs(conf.iter_pos or {}) do
      if filter.run_iter_pos(f,con,range) then
        return true
      end
    end
    return false
  end,
  _name='multi_or',
}

---@type ua.ifilter<ua.filter.multi.conf>
local multi_and={
  once=function(con,conf)
    for _,f in ipairs(conf.once or {}) do
      if not filter.run_once(f,con) then
        return false
      end
    end
    return true
  end,
  iter_pos=function(con,range,conf)
    for _,f in ipairs(conf.iter_pos or {}) do
      if not filter.run_iter_pos(f,con,range) then
        return false
      end
    end
    return true
  end,
  _name='multi_and',
}

return {
  multi_and=multi_and,
  multi_or=multi_or,
}
