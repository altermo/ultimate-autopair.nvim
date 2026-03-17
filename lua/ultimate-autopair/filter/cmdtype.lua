local util=require'ultimate-autopair.util'

---@class ua.filter.cmdtype.conf
---@field skip string[]

---@type ua.filter_fn<ua.filter.cmdtype.conf>
return function(con,_,conf)
  return con.bufnr==nil and util.in_list(conf.skip,vim.fn.getcmdtype())
end
