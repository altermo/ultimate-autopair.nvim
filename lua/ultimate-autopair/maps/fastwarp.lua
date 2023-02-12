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
  while line:sub(j,j):match('%w') do
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
  return utils.delete(0,1)..utils.movel(i-col-1)..next_char..utils.moveh()
end
function M.fastwarp(fallback)
  local line=utils.getline()
  local col=utils.getcol()
  local next_char=line:sub(col,col)
  local next_pair=mem.mem[next_char]
  local key
  if next_pair and next_pair.type~=1 then
    for i=col+1,#line do
      local char=line:sub(i,i)
      if mem.isstart(line,i) then
        key=fastwarp_over_pair(line,col,i,next_char,char)
      elseif mem.isend(line,i) then
        key=fastwarp_next_to_pair(line,col,i,char,next_char)
      elseif char:match('%w') then
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
  if conf.fallback then
    return conf.fallback(fallback or '')
  else
    return fallback or ''
  end
end
function M.create_fastwarp(key)
  return function ()
    return M.fastwarp(key)
  end
end
function M.setup()
  if conf.enable then
    vim.keymap.set('i',conf.map,M.create_fastwarp(),vim.tbl_extend('error',gconf.mapopt,{expr=true}))
    if gconf.cmap and conf.cmap then
      vim.keymap.set('c',conf.map,M.create_fastwarp(),vim.tbl_extend('error',gconf.mapopt,{expr=true}))
    end
  end
end
return M
