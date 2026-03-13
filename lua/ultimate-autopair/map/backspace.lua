local open_pair=require'ultimate-autopair.util.open_pair'
local context=require'ultimate-autopair.util.context'
local utf=require'ultimate-autopair.util.utf'
local filter=require'ultimate-autopair.filter'

local M={}

---@param con ua.context
---@param pair TODO
---@return ua.actions?
local function start_pair_backspace(con,pair)
  local start_pair=utf.raw(pair[1])
  local end_pair=utf.raw(pair[2])
  if not vim.endswith(context.line_before_range(con,con.cursor_range),start_pair) then
    return
  elseif not vim.startswith(context.line_after_range(con,con.cursor_range),end_pair) then
    return
  end

  local start_pair_range={con.cursor_range[1],
  con.cursor_range[2]-#start_pair,
  con.cursor_range[1],con.cursor_range[2]}

  local end_pair_range={con.cursor_range[3],con.cursor_range[4],con.cursor_range[3],
  con.cursor_range[4]+#end_pair}

  if filter.run_pos(pair.start_pair_filter,con,start_pair_range) then
    return
  elseif filter.run_pos(pair.end_pair_filter,con,end_pair_range) then
    return
  end

  local filters={pair.start_pair_filter,pair.end_pair_filter}
  if start_pair==end_pair then
    local not_balanced=open_pair.open_ambiguous_pairs(con.cursor_range,start_pair,con,filters,'both')
    if not_balanced then
      return
    end
  else
    local count=open_pair.count_start_pair(con.cursor_range,start_pair,end_pair,con,filters)
    if not open_pair.count_start_pair(con.cursor_range,start_pair,end_pair,con,filters,true,assert(count)-1) then
      return
    end
  end

  return {{'delete',1,utf.len(pair[2])}}
end

---@param con ua.context
---@param conf TODO
---@return ua.actions?
function M.run(con,conf)
  for _,p in ipairs(conf.pairs) do
    local ret=start_pair_backspace(con,p)
    if ret then
      return ret
    end
  end
end

return M
