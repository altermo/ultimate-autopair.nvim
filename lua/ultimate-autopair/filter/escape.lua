local context=require'ultimate-autopair.util.context'

---@class ua.filter.escape.conf

---@type ua.filter_fn<ua.filter.escape.conf>
return function(con,range)
  return #(context.line_before_range(con,range):match'\\*$')%2==1
end
