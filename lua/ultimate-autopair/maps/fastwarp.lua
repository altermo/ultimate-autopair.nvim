local M={}
local gconf=require'ultimate-autopair.config'.conf
local conf=gconf.fastwarp
local mem=require'ultimate-autopair.memory'
local utils=require'ultimate-autopair.utils.utils'
local info_line=require'ultimate-autopair.utils.info_line'
function M.fastwarp()
  local line=utils.getline()
  local col=utils.getcol()
  local prev_char=line:sub(col-1,col-1)
  local next_char=line:sub(col,col)
  local next_2_char=line:sub(col+1,col+1)
  local prev_pair=mem.mem[prev_char]
  local next_pair=mem.mem[next_char]
  local next_2_pair=mem.mem[next_2_char]
  if prev_pair and next_pair and next_2_pair and prev_pair.paire==next_char and next_pair.pair==prev_char then
    local matching_pair_pos
    if next_2_pair.type==3 then
      matching_pair_pos=info_line.findstringe(line,col+2,next_2_char)
    else
      matching_pair_pos=info_line.findepaire(line,col+2,next_2_char,next_2_pair.paire)
    end
    if matching_pair_pos then
      utils.setline(line:sub(1,col-1)..line:sub(col+1,matching_pair_pos)..next_char..line:sub(matching_pair_pos+1))
      utils.setcursor(matching_pair_pos)
    end
  elseif conf.hopword and next_pair and next_pair.type~=1 then
    local match=vim.fn.match(line:sub(col+1),[[\<.\{-}\>\zs]])
    --TODO if ( before word then fastwarp over pair and not word
    if match~=-1 then
      local end_next_word=match+col
      utils.setline(line:sub(1,col-1)..line:sub(col+1,end_next_word)..next_char..line:sub(end_next_word+1))
      utils.setcursor(end_next_word)
    else
      local end_next_word=#line
      utils.setline(line:sub(1,col-1)..line:sub(col+1,end_next_word)..next_char..line:sub(end_next_word+1))
      utils.setcursor(end_next_word)
    end
  end
  if type(conf.fallback)=='function' then
    conf.fallback()
  elseif conf.fallback then
    vim.api.nvim_feedkeys(conf.fallback,'n',true)
  end
end
function M.setup()
  if conf.enable then
    vim.keymap.set('i',conf.map,M.fastwarp,gconf.mapopt)
    if gconf.cmap and conf.cmap then
      vim.keymap.set('c',conf.cmap,M.fastwarp,gconf.mapopt)
    end
  end
end
return M
