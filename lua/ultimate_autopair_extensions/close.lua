local info_line=require'ultimate-autopair.utils.info_line'
local function run(line,col,pairs,paires)
  local count={}
  for i in #line,col,-1 do
    local char=line:sub(i,i)
    if vim.tbl_contains(char,paires) then
      count[char]=(count[char] or 0)+1
    elseif vim.tbl_contains(char,pairs) then
      count[char]=(count[char] or 0)-1
    end
  end
end
return {call=function ()
end,run=run}
