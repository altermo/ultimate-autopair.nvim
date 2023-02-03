local M={}
local gconf=require'ultimate-autopair.config'.conf
local conf=gconf.bs or {}
local mem=require'ultimate-autopair.memory'
local utils=require'ultimate-autopair.utils.utils'
local info_line=require'ultimate-autopair.utils.info_line'
local open_pair=require'ultimate-autopair.utils.open_pair'
local function delete_mid_pair(prev_pair,prev_char,next_char,line,col)
  if prev_pair.type==3 then
    if not open_pair.open_pair_ambigous(prev_char,line) then
      utils.delete(line,col,1,1)
      return true
    end
  elseif not open_pair.open_pair_before(prev_char,next_char,line,col) then
    utils.delete(line,col,1,1)
    return true
  end
end
local function delete_prev_pair(prev_pair,prev_char,prev_2_char,line,col)
  if prev_pair.type==3 then
    if not open_pair.open_pair_ambigous(prev_char,line) then
      utils.delete(line,col,2)
      return true
    end
  elseif not open_pair.open_paire_after(prev_2_char,prev_char,line,col) then
    utils.delete(line,col,2)
    return true
  end
end
local function delete_overjump_pair(prev_pair,prev_char,line,col)
  local matching_pair_pos=info_line.findepaire(line,col,prev_char,prev_pair.paire)
  if matching_pair_pos then
    utils.setline(line:sub(1,col-2)..line:sub(col,matching_pair_pos-1)..line:sub(matching_pair_pos+1))
    utils.moveh()
    return true
  end
end
local function delete_space(line,col)
  local newcol
  local char
  for i=col-2,1,-1 do
    char=line:sub(i,i)
    if char~=' ' then
      newcol=i+2
      break
    end
  end
  local prev_n_pair=mem.mem[char]
  if prev_n_pair and prev_n_pair.type==1 then
    local matching_pair_pos=info_line.findepaire(line,newcol-1,char,prev_n_pair.paire)
    if matching_pair_pos and col-newcol<matching_pair_pos-col and line:sub(matching_pair_pos-1,matching_pair_pos-1)==' ' then
      utils.setline(line:sub(1,newcol-2)..line:sub(newcol,matching_pair_pos-2)..line:sub(matching_pair_pos))
      utils.moveh()
      return true
    end
  end
end
local function delete_multichar(line,col)
  for newkey,opt in pairs(mem.mem) do
    local bool=#newkey>1 and opt.type~=2
    if bool and opt.ext.filetype and #opt.ext.filetype~=0 then
      bool=opt.ext.filetype[vim.o.filetype]
    end
    if bool and vim.tbl_contains(mem.extensions.multichar.conf or {},newkey) then
      bool=not line:sub(col-#newkey-1,col-#newkey-1):match('%a')
    end
    if bool and line:sub(col-#newkey,col-1)==newkey then
      utils.delete(line,col,#newkey,#newkey)
      return
    end
  end
end
function M.backspace()
  local line=utils.getline()
  local col=utils.getcol()
  local prev_char=line:sub(col-1,col-1)
  local next_char=line:sub(col,col)
  local prev_pair=mem.mem[prev_char]
  local next_pair=mem.mem[next_char]
  if prev_pair and next_pair and prev_pair.paire==next_char and next_pair.pair==prev_char then
    if delete_mid_pair(prev_pair,prev_char,next_char,line,col) then
      return
    end
  elseif conf.overjump and prev_pair and prev_pair.type==1 then
    if not open_pair.open_pair_before(prev_char,prev_pair.paire,line,col) then
      if delete_overjump_pair(prev_pair,prev_char,line,col) then
        return
      end
    end
  elseif prev_pair and prev_pair.type~=1 then
    local prev_2_char=line:sub(col-2,col-2)
    local prev_2_pair=mem.mem[prev_2_char]
    if prev_2_pair and prev_2_pair.type~=2 and prev_2_pair.paire==prev_char then
      if delete_prev_pair(prev_pair,prev_char,prev_2_char,line,col) then
        return
      end
    end
  elseif conf.space and prev_char==' ' then
    if delete_space(line,col) then
      return
    end
  elseif conf.multichar and mem.extensions.multichar then
    if delete_multichar(line,col) then
      return
    end
  end
  if type(conf.fallback)=='function' then
    conf.fallback()
  else
    vim.api.nvim_feedkeys(conf.fallback or '\x80kb','n',true)
  end
end
function M.setup()
  if conf.enable then
    vim.keymap.set('i','<bs>',M.backspace,gconf.mapopt)
    if gconf.cmap then
      vim.keymap.set('c','<bs>',M.backspace,gconf.mapopt)
    end
  end
end
return M
