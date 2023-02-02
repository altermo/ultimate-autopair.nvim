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
  for i=col-1,1,-1 do
    prev_char=line:sub(i,i)
    if prev_char~=' ' then
      col=i+1
      break
    end
  end
  local prev_pair=mem.mem[prev_char]
  if prev_pair and prev_pair.type==1 then
    local matching_pair_pos=info_line.findepaire(line,col,prev_pair,prev_pair.paire)
    if matching_pair_pos then
      utils.movel()
      utils.setline(line:sub(1,col-1)..' '..line:sub(col,matching_pair_pos-1)..' '..line:sub(matching_pair_pos))
      return
    end
  end
  if type(conf.fallback)=='function' then
    conf.fallback()
  else
    vim.api.nvim_feedkeys(conf.fallback or ' ','n',true)
  end
end
function M.setup()
  if conf.enable then
    vim.keymap.set('i',' ',M.space,gconf.mapopt)
    if gconf.cmap then
      vim.keymap.set('c',' ',M.space,gconf.mapopt)
    end
  end
end
return M
