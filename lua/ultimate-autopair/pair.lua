local open_pair=require'ultimate-autopair.util.open_pair'
local M={}

---@param con ua.context
---@param conf TODO
---@return ua.actions?
function M.run_start(con,conf)
  local start_pair,end_pair=unpack(conf)

  local pair_range={con.cursor_range[1],
  con.cursor_range[2]-(#start_pair-1),
  con.cursor_range[1],con.cursor_range[2]}

  local testfns;testfns=setmetatable({},{
    __index=function() return testfns end,
    __call=function() return true end,
  }) --[[@as TODO]]

  if start_pair==end_pair then
    error'TODO'
  else
    local count1=open_pair.count_start_pair(pair_range,start_pair,end_pair,con,testfns)
    local count2=open_pair.count_end_pair(pair_range,start_pair,end_pair,con,testfns)
    if count1<count2 then return end
  end

  return {start_pair..end_pair,{'h',#end_pair}}
end

---@param con ua.context
---@param conf TODO
---@return ua.actions?
function M.run_end(con,conf)
  local start_pair,end_pair=unpack(conf)

  local pair_range={con.cursor_range[3],con.cursor_range[4],con.cursor_range[3],
  con.cursor_range[4]+#end_pair}

  local testfns;testfns=setmetatable({},{
    __index=function() return testfns end,
    __call=function() return true end,
  }) --[[@as TODO]]

  if start_pair==end_pair then
    error'TODO'
  else
    local count1=open_pair.count_start_pair(pair_range,start_pair,end_pair,con,testfns)
    local count2=open_pair.count_end_pair(pair_range,start_pair,end_pair,con,testfns,nil,1)
    if count1==0 or count1>count2 then return end
  end
  return {
    {'l',#end_pair},
  }
end

return M
