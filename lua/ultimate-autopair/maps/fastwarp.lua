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
    return utils.delete(0,1)..utils.movel(matching_pair_pos-col)..next_char..utils.moveh()
  end
end
local function fastwarp_over_word(line,col,i,next_char)
  local j=i
  while line:sub(j,j):match('%a') do
    j=j+1
  end
  return utils.delete(0,1)..utils.movel(j-col-1)..next_char..utils.moveh()
end
local function fastwarp_end(line,_,next_char)
  return utils.delete(0,1)..utils.movel(#line)..next_char..utils.moveh()
end
local function fastwarp_next_to_pair(line,col,i,char,next_char)
  if line:sub(col+1,col+1)==char then
    return
  end
  return utils.delete(0,1)..utils.movel(i-col)..next_char..utils.moveh()
end
function M.fastwarp()
  local line=utils.getline()
  local col=utils.getcol()
  local next_char=line:sub(col,col)
  local next_pair=mem.mem[next_char]
  local key
  if next_pair then
    for i=col+1,#line do
      local char=line:sub(i,i)
      if mem.mem[char] and mem.mem[char].type~=2 then
        key=fastwarp_over_pair(line,col,i,next_char,char)
      elseif mem.mem[char] and mem.mem[char].type==2 then
        key=fastwarp_next_to_pair(line,col,i,char,next_char)
      elseif char:match('%a') then
        key=fastwarp_over_word(line,col,i,next_char)
      end
      if key then
        break
      end
    end
    if not key and col~=#line then
      key=fastwarp_end(line,col,next_char)
    end
  end
  if key then
    return key
  end
  if type(conf.fallback)=='function' then
    return conf.fallback()
  elseif conf.fallback then
    return conf.fallback
  end
end
function M.setup()
  if conf.enable then
    vim.keymap.set('i',conf.map,M.fastwarp,vim.tbl_extend('error',gconf.mapopt,{expr=true}))
    if gconf.cmap and conf.cmap then
      vim.keymap.set('c',conf.map,M.fastwarp,vim.tbl_extend('error',gconf.mapopt,{expr=true}))
    end
  end
end
return M
