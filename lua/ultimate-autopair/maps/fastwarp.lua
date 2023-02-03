local M={}
local gconf=require'ultimate-autopair.config'.conf
local conf=gconf.fastwarp
local mem=require'ultimate-autopair.memory'
local utils=require'ultimate-autopair.utils.utils'
local info_line=require'ultimate-autopair.utils.info_line'
local function fastwarp_over_pair(line,col,i,next_char,char)
  local pair=mem.mem[char]
  local matching_pair_pos
  if pair.type==3 then
    matching_pair_pos=info_line.findstringe(line,i+1,char)
  else
    matching_pair_pos=info_line.findepaire(line,i+1,char,pair.paire)
  end
  if matching_pair_pos then
    utils.setline(line:sub(1,col-1)..line:sub(col+1,matching_pair_pos)..next_char..line:sub(matching_pair_pos+1))
    utils.setcursor(matching_pair_pos)
    return true
  end
end
local function fastwarp_over_word(line,col,i,next_char)
  local j=i
  while line:sub(j,j):match('%a') do
    j=j+1
  end
  utils.setline(line:sub(1,col-1)..line:sub(col+1,j-1)..next_char..line:sub(j))
  utils.setcursor(j-1)
  return true
end
local function fastwarp_end(line,col,next_char)
  utils.setline(line:sub(1,col-1)..line:sub(col+1)..next_char)
  utils.setcursor(#line)
  return true
end
local function fastwarp_next_to_pair(line,col,i,char,next_char)
  if line:sub(col+1,col+1)==char then
    return
  end
  utils.setline(line:sub(1,col-1)..line:sub(col+1,i-1)..next_char..line:sub(i))
  utils.setcursor(i-1)
  return true
end
function M.fastwarp()
  local line=utils.getline()
  local col=utils.getcol()
  local next_char=line:sub(col,col)
  local next_pair=mem.mem[next_char]
  if next_pair then
    for i=col+1,#line do
      local char=line:sub(i,i)
      if mem.mem[char] and mem.mem[char].type~=2 then
        if fastwarp_over_pair(line,col,i,next_char,char) then
          return
        end
      elseif mem.mem[char] and mem.mem[char].type==2 then
        if fastwarp_next_to_pair(line,col,i,char,next_char) then
          return
        end
      elseif char:match('%a') then
        if fastwarp_over_word(line,col,i,next_char) then
          return
        end
      end
    end
    if col~=#line then
      if fastwarp_end(line,col,next_char) then
        return
      end
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
