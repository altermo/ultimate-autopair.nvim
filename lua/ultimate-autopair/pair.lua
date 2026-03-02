local open_pair=require'ultimate-autopair.util.open_pair'
local context=require'ultimate-autopair.util.context'
local utf=require'ultimate-autopair.util.utf'
local M={}

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

  local testfn=function()
    return true
  end
  local testfns={testfn,testfn}

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

  local testfns;testfns=setmetatable({},{
    __index=function() return testfns end,
    __call=function() return true end,
  }) --[[@as TODO]]

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
