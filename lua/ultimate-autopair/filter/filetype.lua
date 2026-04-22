local treesitter=require'ultimate-autopair.util.treesitter'
local util=require'ultimate-autopair.util'
local context=require'ultimate-autopair.util.context'

---@class ua.filter.filetype.conf
---@field injectlang_separate boolean?

---@param con ua.context
---@param range Range4
---@return TSTree?
local function in_tree(con,range)
  if not con.parser then return end
  local tree,top=treesitter.find_smallest_tree(con,range,con.parser)
  return not top and tree or nil
end

---@type ua.filter_fn<ua.filter.filetype.conf>
return function(con,range,conf,single)
    if conf.injectlang_separate and con.parser then
      if single then
        local tree=in_tree(con,range)
        context.set_state(con,in_tree,conf,tree and treesitter.tree_to_ranges(tree) or false)
      else
        local tree_ranges=context.get_state(con,in_tree,conf)
        if tree_ranges==false then
          return in_tree(con,range) and true or false
        elseif tree_ranges~=nil then
          for _,tree_range in ipairs(tree_ranges) do
            return not util.range_in_range(tree_range,range)
          end
        end
      end
    end
end
