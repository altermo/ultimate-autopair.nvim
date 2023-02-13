local M={}
M.extensions={}
local gconf=require'ultimate-autopair.config'.conf
local conf=gconf.bs or {}
local mem=require'ultimate-autopair.memory'
local utils=require'ultimate-autopair.utils.utils'
local info_line=require'ultimate-autopair.utils.info_line'
local open_pair=require'ultimate-autopair.utils.open_pair'
function M.extensions.delete_mid_pair(prev_char,next_char,line,col)
  if mem.ispair(prev_char,next_char) then
    if mem.mem[prev_char].type==3 then
      if not open_pair.open_pair_ambigous(prev_char,line) then
        return utils.delete(1,1)
      end
    elseif not open_pair.open_pair_before(prev_char,next_char,line,col) then
      return utils.delete(1,1)
    end
  end
end
function M.extensions.delete_prev_pair(prev_char,_,line,col)
  local prev_pair=mem.mem[prev_char]
  if prev_pair and prev_pair.type~=1 then
    local prev_2_char=line:sub(col-2,col-2)
    if mem.ispair(prev_2_char,prev_char) then
      if prev_pair.type==3 then
        if not open_pair.open_pair_ambigous(prev_char,line) then
          return utils.delete(2)
        end
      elseif not open_pair.open_paire_after(prev_2_char,prev_char,line,col) then
        return utils.delete(2)
      end
    end
  end
end
function M.extensions.delete_overjump_pair(prev_char,_,line,col)
  local prev_pair=mem.mem[prev_char]
  if conf.overjump and prev_pair and prev_pair.type==1 then
    if not open_pair.open_pair_before(prev_char,prev_pair.paire,line,col) then
      local matching_pair_pos=info_line.findepaire(line,col,prev_char,prev_pair.paire)
      if matching_pair_pos then
        return utils.delete(1)..utils.addafter(matching_pair_pos-col,utils.delete(0,1),0)
      end
    end
  end
end
function M.extensions.delete_space(prev_char,_,line,col)
  if conf.space and prev_char==' ' then
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
        return utils.moveh(col-newcol)..utils.delete(1)..utils.addafter(matching_pair_pos-col-1,utils.delete(0,1),-(col-newcol))
      end
    end
  end
end
function M.extensions.delete_multichar(_,_,line,col)
  if conf.multichar and mem.extensions.multichar then
    for newkey,opt in pairs(mem.mem) do
      local bool=#newkey>1 and opt.type~=2
      if bool and opt.ext.filetype and #opt.ext.filetype~=0 then
        bool=opt.ext.filetype[vim.o.filetype]
      end
      if bool and opt.ext.alpha and vim.tbl_contains(opt.ext.alpha.before or {},newkey) then
        bool=not line:sub(col-#newkey-1,col-#newkey-1):match('%a')
      end
      if bool and line:sub(col-#newkey,col-1)==newkey and opt.paire==line:sub(col,col+#opt.paire-1) then
        return utils.delete(#newkey,#opt.paire)
      end
    end
  end
end
function M.backspace(fallback)
  local wline=utils.getline()
  local wcol=utils.getcol()
  local line,col=info_line.filter_string(wline,wcol,utils.getlinenr(),conf.notree)
  local prev_char=line:sub(col-1,col-1)
  local next_char=line:sub(col,col)
  for _,i in pairs(M.extensions) do
    local ret=i(prev_char,next_char,line,col)
    if ret then
      return ret
    end
  end
  if conf.fallback then
    return conf.fallback(fallback or '<bs>')
  else
    return fallback or '<bs>'
  end
end
function M.create_backspace(key)
  return function ()
    return M.backspace(key)
  end
end
function M.setup()
  if conf.enable then
    vim.keymap.set('i','<bs>',M.create_backspace(),vim.tbl_extend('error',gconf.mapopt,{expr=true}))
    if gconf.cmap then
      vim.keymap.set('c','<bs>',M.create_backspace(),vim.tbl_extend('error',gconf.mapopt,{expr=true}))
    end
  end
end
return M
