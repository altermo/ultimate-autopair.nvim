local function run(line,col,pair)
  local beg_pair={}
  local end_pair={}
  local map={}
  for _,v in pairs(pair) do
    beg_pair[#beg_pair+1]=v[1]
    end_pair[#end_pair+1]=v[2]
    map[v[1]]=v[2]
  end
  local stack={}
  for i=1,col-1 do
    local char=line:sub(i,i)
    if vim.tbl_contains(end_pair,char) then
      stack[#stack]=nil
    elseif vim.tbl_contains(beg_pair,char) then
      stack[#stack+1]=char
    end
  end
  local ret={}
  for _,i in pairs(vim.fn.reverse(stack)) do
    ret[#ret+1]=map[i]
  end
  return vim.fn.join(ret,'')
end
return {call=function (_,conf)
  if not conf.disable_pair then
    return --not implemented
  end
end,run=run}
