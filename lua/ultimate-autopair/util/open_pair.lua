local M={}

---@param s string
---@return number
local function slenmin1char(s)
  local utf=require'ultimate-autopair.util.utf'
  return #utf.sub(utf.new(s),0,-2)
end

local to_excludefn
do
  local filter=require'ultimate-autopair.util.filter'

  ---@param start_pair string
  ---@param end_pair string
  ---@param filters [ua.filter,ua.filter]
  ---@param con ua.context
  ---@return ua.excludefn
  ---@return ua.excludefn
  function to_excludefn(filters,start_pair,end_pair,con)
    return function(row,col)
        local range={row-1,col-1,row-1,col-1+#start_pair}
        ---@cast range Range4
        return not filter.run_pos(filters[1],con,range)
      end,function(row,col)
        local range={row-1,col-2+#end_pair,row-1,col-2+#end_pair+#end_pair}
        ---@cast range Range4
        return not filter.run_pos(filters[2],con,range)
      end
  end
end

---If {gotostart_ret_pos} is false(/nil), returns the number of open END pairs or nil
---If {gotostart_ret_pos} is true, returns the start position of the LAST open START pair or nil
---Normally, it searches the range {-1,-1}(end of source) to {row,col}
---{gotostart_ret_pos} makes it search the range {row,col} to {0,0}
---@param range Range4
---@param start_pair_match string
---@param end_pair_match string
---@param con ua.context
---@param filters [ua.filter,ua.filter]
---@param gotostart_ret_pos boolean?
---@param initial_count number?
---@return number?
---@return number?
function M.count_end_pair(
  range,
  start_pair_match,
  end_pair_match,
  con,
  filters,
  gotostart_ret_pos,
  initial_count)
  assert(start_pair_match~=end_pair_match)
  assert(#start_pair_match>0)
  assert(#end_pair_match>0)
  local row=(gotostart_ret_pos and range[1]+1) or range[3]+1
  local col=(gotostart_ret_pos and range[2]+1) or range[4]+1
  local excludefn_start_pair,excludefn_end_pair=to_excludefn(filters,start_pair_match,end_pair_match,con)
  start_pair_match=start_pair_match:reverse()
  end_pair_match=end_pair_match:reverse()
  local count=0
  local start_row=(gotostart_ret_pos and row) or -1
  local end_row=(gotostart_ret_pos and 1) or row
  for lrow,line in con.iter_lines(start_row,end_row) do
    local rline=line:reverse()
    local rev_find_start=1
    local find_end=1
    if not gotostart_ret_pos and lrow==row then
      find_end=col
    elseif gotostart_ret_pos and lrow==row then
      rev_find_start=#line+1-col+1
    end
    local next_start_pair=rline:find(start_pair_match,rev_find_start,true)
    local next_end_pair=rline:find(end_pair_match,rev_find_start,true)
    while true do
      if next_start_pair and next_start_pair<(next_end_pair or math.huge) then
        local rcol=#line-next_start_pair+1-#start_pair_match+1
        if rcol<find_end then
          goto continue
        end
        if excludefn_start_pair(lrow,rcol) then
          count=count-1
          if count<0 then
            if gotostart_ret_pos then
              return lrow,rcol
            end
            count=0
          end
          next_start_pair=rline:find(start_pair_match,next_start_pair+#start_pair_match,true)
        else
          next_start_pair=rline:find(start_pair_match,next_start_pair+1,true)
        end
      elseif next_end_pair then
        local rcol=#line-next_end_pair+1-#end_pair_match+1
        if rcol<find_end then
          goto continue
        end
        if excludefn_end_pair(lrow,rcol) then
          count=count+1
          next_end_pair=rline:find(end_pair_match,next_end_pair+#end_pair_match,true)
        else
          next_end_pair=rline:find(end_pair_match,next_end_pair+1,true)
        end
      else
        break
      end
    end
    ::continue::
  end
  return (not gotostart_ret_pos) and count+(initial_count or 0) or nil
end
---If {gotoend_ret_pos} is false(/nil), returns the number of open START pairs or nil
---If {gotoend_ret_pos} is true, returns the start position of the FIRST open END pair or nil
---Normally, it searches the range {0,0} to {row,col}
---{gotoend_ret_pos} makes it search the range {row,col} to {-1,-1}(end of source)
---@param range Range4
---@param start_pair_match string
---@param end_pair_match string
---@param filters [ua.filter,ua.filter]
---@param con ua.context
---@param gotoend_ret_pos boolean?
---@param initial_count number?
---@return number?
---@return number?
function M.count_start_pair(
  range,
  start_pair_match,
  end_pair_match,
  con,
  filters,
  gotoend_ret_pos,
  initial_count)
  assert(start_pair_match~=end_pair_match)
  assert(#start_pair_match>0)
  assert(#end_pair_match>0)
  local row=(gotoend_ret_pos and range[3]+1) or range[1]+1
  local col=(gotoend_ret_pos and range[4]+1) or range[2]+1
  local count=initial_count or 0
  local start_row=(gotoend_ret_pos and row) or 1
  local end_row=(gotoend_ret_pos and -1) or row
  local excludefn_start_pair,excludefn_end_pair=to_excludefn(filters,start_pair_match,end_pair_match,con)
  local start_offset_len=slenmin1char(start_pair_match)
  local end_offset_len=slenmin1char(end_pair_match)
  for lrow,line in con.iter_lines(start_row,end_row) do
    local find_start=1
    local find_end=math.huge
    if not gotoend_ret_pos and lrow==row then
      find_end=col-1
    elseif gotoend_ret_pos and lrow==row then
      find_start=col
    end
    local next_start_pair=line:find(start_pair_match,find_start,true)
    local next_end_pair=line:find(end_pair_match,find_start,true)
    while true do
      if next_start_pair and next_start_pair<(next_end_pair or math.huge) then
        local rcol=next_start_pair
        if rcol+start_offset_len>find_end then
          goto continue
        end
        if excludefn_start_pair(lrow,rcol) then
          count=count+1
          next_start_pair=line:find(start_pair_match,next_start_pair+#start_pair_match,true)
        else
          next_start_pair=line:find(start_pair_match,next_start_pair+1,true)
        end
      elseif next_end_pair then
        local rcol=next_end_pair
        if rcol+end_offset_len>find_end then
          goto continue
        end
        if excludefn_end_pair(lrow,rcol) then
          count=count-1
          if count<0 then
            if gotoend_ret_pos then
              return lrow,rcol
            end
            count=0
          end
          next_end_pair=line:find(end_pair_match,next_end_pair+#end_pair_match,true)
        else
          next_end_pair=line:find(end_pair_match,next_end_pair+1,true)
        end
      else
        break
      end
    end
    ::continue::
  end
  return (not gotoend_ret_pos) and count or nil
end
---@param range Range4
---@param pair_match string
---@param con ua.context
---@param filters [ua.filter,ua.filter]
---@param gotoend 'both'|true?
---@param initial_count number?
---@return number?
---@return number?
function M.open_ambiguous_pairs(
  range,
  pair_match,
  con,
  filters,
  gotoend,
  initial_count)
  assert(#pair_match>0)
  local pos_row=initial_count
  local pos_col
  local row=(gotoend and range[3]+1) or range[1]+1
  local col=(gotoend and range[4]+1) or range[2]+1
  local start_row=(gotoend==true and row) or 1
  local end_row=(not gotoend and -1) or row
  local count=initial_count or 0
  local excludefn_start_pair,excludefn_end_pair=to_excludefn(filters,pair_match,pair_match,con)
  local offset_len=slenmin1char(pair_match)
  for lrow,line in con.iter_lines(start_row,end_row) do
    local find_start=1
    local find_end=math.huge
    if not gotoend and lrow==row then
      find_end=col-1
    elseif gotoend==true and lrow==row then
      find_start=col
    end
    local next_pair=line:find(pair_match,find_start,true)
    while true do
      if not next_pair then
        break
      end
      local rcol=next_pair
      if rcol+offset_len>find_end then
        goto continue
      end
      if ((count%2==0 and excludefn_start_pair(lrow,rcol)) or
        (count%2==1 and excludefn_end_pair(lrow,rcol))) then
        count=count+1
        next_pair=line:find(pair_match,next_pair+#pair_match,true)
        if not gotoend or not pos_col then
          pos_row=lrow
          pos_col=rcol
        end
      else
        next_pair=line:find(pair_match,next_pair+1,true)
      end
    end
    ::continue::
  end
  if count%2==0 then return end
  return pos_row,pos_col
end

return M
