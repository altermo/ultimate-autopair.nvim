local treesitter=require'ultimate-autopair.util.treesitter'
local util=require'ultimate-autopair.util'

---@class ua.filter.tsnode.conf
---@field ignore string[]?

---@type ua.filter_fn<ua.filter.tsnode.conf>
return function(con,range,conf)
  if not conf.ignore then
    return
  end

  return treesitter.find_node(con,range,function(node)
    return util.in_list(conf.ignore,node:type())
  end) and true or false
end
