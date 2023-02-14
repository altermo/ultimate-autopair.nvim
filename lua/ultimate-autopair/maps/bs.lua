local M={}
M.extensions={}
local gconf=require'ultimate-autopair.config'.conf
M.conf=gconf.bs or {}
local mem=require'ultimate-autopair.memory'
local utils=require'ultimate-autopair.utils.utils'
local info_line=require'ultimate-autopair.utils.info_line'
local open_pair=require'ultimate-autopair.utils.open_pair'
function M.extensions.delete_mid_pair(o)
  if mem.ispair(o.prev_char,o.next_char) then
    if mem.mem[o.prev_char].type==3 then
      if not open_pair.open_pair_ambigous(o.prev_char,o.line) then
        return utils.delete(1,1)
      end
    elseif not open_pair.open_pair_before(o.prev_char,o.next_char,o.line,o.col) then
      return utils.delete(1,1)
    end
  end
end
function M.extensions.delete_prev_pair(o)
  local prev_pair=mem.mem[o.prev_char]
  if prev_pair and prev_pair.type~=1 then
    local prev_2_char=o.line:sub(o.col-2,o.col-2)
    if mem.ispair(prev_2_char,o.prev_char) then
      if prev_pair.type==3 then
        if not open_pair.open_pair_ambigous(o.prev_char,o.line) then
          return utils.delete(2)
        end
      elseif not open_pair.open_paire_after(prev_2_char,o.prev_char,o.line,o.col) then
        return utils.delete(2)
      end
    end
  end
end
function M.extensions.delete_overjump_pair(o)
  local prev_pair=mem.mem[o.prev_char]
  if o.conf.overjump and prev_pair and prev_pair.type==1 then
    if not open_pair.open_pair_before(o.prev_char,prev_pair.paire,o.line,o.col) then
      local matching_pair_pos=info_line.findepaire(o.line,o.col,o.prev_char,prev_pair.paire)
      if matching_pair_pos then
        return utils.delete(1)..utils.addafter(matching_pair_pos-o.col,utils.delete(0,1),0)
      end
    end
  end
end
function M.extensions.delete_space(o)
  if o.conf.space and o.prev_char==' ' then
    local newcol
    local char
    for i=o.col-2,1,-1 do
      char=o.line:sub(i,i)
      if char~=' ' then
        newcol=i+2
        break
      end
    end
    local prev_n_pair=mem.mem[char]
    if prev_n_pair and prev_n_pair.type==1 then
      local matching_pair_pos=info_line.findepaire(o.line,newcol-1,char,prev_n_pair.paire)
      if matching_pair_pos and o.col-newcol<matching_pair_pos-o.col and o.line:sub(matching_pair_pos-1,matching_pair_pos-1)==' ' then
        return utils.moveh(o.col-newcol)..utils.delete(1)..utils.addafter(matching_pair_pos-o.col-1,utils.delete(0,1),-(o.col-newcol))
      end
    end
  end
end
function M.extensions.delete_multichar(o)
  if o.conf.multichar and mem.extensions.multichar then
    for newkey,opt in pairs(mem.mem) do
      local bool=#newkey>1 and opt.type~=2
      if bool and opt.ext.filetype and #opt.ext.filetype~=0 then
        bool=opt.ext.filetype[vim.o.filetype]
      end
      if bool and opt.ext.alpha and vim.tbl_contains(opt.ext.alpha.before or {},newkey) then
        bool=not o.line:sub(o.col-#newkey-1,o.col-#newkey-1):match('%a')
      end
      if bool and o.line:sub(o.col-#newkey,o.col-1)==newkey and opt.paire==o.line:sub(o.col,o.col+#opt.paire-1) then
        return utils.delete(#newkey,#opt.paire)
      end
    end
  end
end
function M.backspace(conf,fallback)
  local o={}
  o.conf=vim.tbl_extend('force',M.conf,conf or {})
  o.wline=utils.getline()
  o.wcol=utils.getcol()
  o.line,o.col=info_line.filter_string(o.wline,o.wcol,utils.getlinenr(),o.conf.notree)
  o.prev_char=o.line:sub(o.col-1,o.col-1)
  o.next_char=o.line:sub(o.col,o.col)
  for _,i in pairs(M.extensions) do
    local ret=i(o)
    if ret then
      return ret
    end
  end
  if o.conf.fallback then
    return o.conf.fallback(fallback or '<bs>')
  else
    return fallback or '<bs>'
  end
end
function M.create_backspace(conf,key)
  return function ()
    return M.backspace(conf,key)
  end
end
function M.setup()
  if M.conf.enable then
    vim.keymap.set('i','<bs>',M.create_backspace(),vim.tbl_extend('error',gconf.mapopt,{expr=true}))
    if gconf.cmap then
      vim.keymap.set('c','<bs>',M.create_backspace(),vim.tbl_extend('error',gconf.mapopt,{expr=true}))
    end
  end
end
return M
