local M={}
local gconf=require'ultimate-autopair.config'.conf
local conf=gconf.space or {}
local mem=require'ultimate-autopair.memory'
local utils=require'ultimate-autopair.utils.utils'
local info_line=require'ultimate-autopair.utils.info_line'
function M.space()
  local line=utils.getline()
  local col=utils.getcol()
  local prev_char
  local pcol=col
  for i=col-1,1,-1 do
    prev_char=line:sub(i,i)
    if prev_char~=' ' then
      pcol=i+1
      break
    end
  end
  local prev_pair=mem.mem[prev_char]
  if prev_pair and prev_pair.type==1 then
    local matching_pair_pos=info_line.findepaire(line,pcol,prev_pair,prev_pair.paire)
    if matching_pair_pos then
      return ' '..utils.movel(matching_pair_pos-col)..' '..utils.moveh(matching_pair_pos-col+1)
    end
  end
  if type(conf.fallback)=='function' then
    return conf.fallback()
  else
    return '\x1d '
  end
end
function M.setup()
  if conf.enable then
    vim.keymap.set('i',' ',M.space,vim.tbl_extend('error',gconf.mapopt,{expr=true}))
    if gconf.cmap then
      vim.keymap.set('c',' ',M.space,vim.tbl_extend('error',gconf.mapopt,{expr=true}))
    end
  end
end
return M
