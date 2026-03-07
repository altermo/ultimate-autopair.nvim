local open_pair=require'ultimate-autopair.util.open_pair'
local context=require'ultimate-autopair.util.context'
local utf=require'ultimate-autopair.util.utf'
local filter=require'ultimate-autopair.util.filter'
local M={}

---@param con ua.context
---@param conf TODO
---@param start_pair string
---@param end_pair string
---@return ua.exclude_testfns
local function conf_get_testfns(con,conf,start_pair,end_pair)
  return {
    function(row,col)
      local range={row-1,col-1,row-1,col-1+#start_pair}
      return filter.run_pos(conf.start_pair_filter,con,range)
    end,
    function(row,col)
      local range={row-1,col-2+#end_pair,row-1,col-2+#end_pair+#end_pair}
      return filter.run_pos(conf.end_pair_filter,con,range)
    end
  }
end

---@param con ua.context
---@param conf TODO
---@param start_pair string
---@param end_pair string
---@return true?
local function start_pair_check(con,conf,start_pair,end_pair)
  local _=conf

  local pair_range={con.cursor_range[1],
  con.cursor_range[2]-(#start_pair-1),
  con.cursor_range[1],con.cursor_range[2]}

  if not filter.run_pos(conf.start_pair_filter,con,con.cursor_range) then
    return
  end

  local testfns=conf_get_testfns(con,conf,start_pair,end_pair)

  if start_pair==end_pair then
    local balanced=open_pair.open_ambiguous_pairs(pair_range,start_pair,con,testfns,'both')
    if balanced then
      return
    end
  else
    local count1=open_pair.count_start_pair(pair_range,start_pair,end_pair,con,testfns)
    local count2=open_pair.count_end_pair(pair_range,start_pair,end_pair,con,testfns)
    if count1<count2 then return end
  end

  return true
end

---@param con ua.context
---@param conf TODO
---@return ua.actions?
function M.run_start(con,conf)
  local start_pair,end_pair=unpack(conf)

  if not vim.endswith(context.line_before_range(con,con.cursor_range),utf.sub(start_pair,1,-2)) then
    return
  end

  if not filter.run_pos(conf.end_pair_filter,con,con.cursor_range) then
    return
  end

  if not start_pair_check(con,conf,utf.raw(start_pair),utf.raw(end_pair)) then
    return
  end

  return {utf.sub(start_pair,-1)..utf.raw(end_pair),{'h',utf.len(end_pair)}}
end

---@param con ua.context
---@param conf TODO
---@param start_pair string
---@param end_pair string
---@return true?
local function end_pair_check(con,conf,start_pair,end_pair)
  local _=conf

  local pair_range={con.cursor_range[3],con.cursor_range[4],con.cursor_range[3],
  con.cursor_range[4]+#end_pair}

  local testfns=conf_get_testfns(con,conf,start_pair,end_pair)

  if start_pair==end_pair then
    local open_pair_before=open_pair.open_ambiguous_pairs(pair_range,start_pair,con,testfns)
    if not open_pair_before then return end
    local open_pair_after=open_pair.open_ambiguous_pairs(pair_range,start_pair,con,testfns,true,2)
    if open_pair_after then return end
  else
    local count1=open_pair.count_start_pair(pair_range,start_pair,end_pair,con,testfns)
    local count2=open_pair.count_end_pair(pair_range,start_pair,end_pair,con,testfns,nil,1)
    if count1==0 or count1>count2 then return end
  end

  return true
end

---@param con ua.context
---@param conf TODO
---@return ua.actions?
function M.run_end(con,conf)
  local start_pair,end_pair=unpack(conf)

  if not vim.startswith(context.line_after_range(con,con.cursor_range),utf.raw(end_pair)) then
    return
  end

  if not end_pair_check(con,conf,utf.raw(start_pair),utf.raw(end_pair)) then
    return
  end

  return {
    {'l',utf.len(end_pair)},
  }
end

return M
