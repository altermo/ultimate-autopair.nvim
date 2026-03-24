local treesitter=require'ultimate-autopair.util.treesitter'
local util=require'ultimate-autopair.util'
local context=require'ultimate-autopair.util.context'

---@class ua.filter.tsnode.conf
---@field ignore string[]?
---@field separate string[]?

---@param con ua.context
---@param range Range4
---@param nodes string[]
---@return TSNode?
local function in_node(con,range,nodes)
    return treesitter.find_node(con,range,function(node)
      return util.in_list(nodes,node:type())
    end)
end

---@type ua.filter_fn<ua.filter.tsnode.conf>
return function(con,range,conf,single)
  if not con.parser then
    return
  end

  if conf.ignore then
    return in_node(con,range,conf.ignore) and true or false
  end

  if conf.separate then
    if single then
      local node=in_node(con,range,conf.separate)
      context.set_state(con,in_node,conf,node and {node:range()} or false)
    else
      local node_range=context.get_state(con,in_node,conf)
      if node_range==false then
        return in_node(con,range,conf.separate) and true or false
      elseif node_range~=nil then
        return not util.range_in_range(node_range,range)
      end
    end
  end
end
