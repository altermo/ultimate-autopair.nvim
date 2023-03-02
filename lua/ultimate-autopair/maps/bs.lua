local M={}
M.ext={}
local mem=require'ultimate-autopair.memory'
local utils=require'ultimate-autopair.utils.utils'
local info_line=require'ultimate-autopair.utils.info_line'
local open_pair=require'ultimate-autopair.utils.open_pair'
function M.ext.delete_multichar(o)
  if o.conf.multichar and mem.extensions.multichar then
    for newkey,opt in pairs(mem.mem) do
      local bool=#newkey>1 and opt.type~=2
      if bool and opt.keyconf.ft then
        bool=vim.tbl_contains(opt.keyconf.ft,vim.o.filetype)
      end
      if bool and mem.extensions.alpha and vim.tbl_contains(mem.extensions.alpha.conf.before or {},newkey) then
        bool=not o.line:sub(o.col-#newkey-1,o.col-#newkey-1):match('%a')
      end
      if bool and o.line:sub(o.col-#newkey,o.col-1)==newkey and opt.paire==o.line:sub(o.col,o.col+#opt.paire-1) then
        return utils.delete(#newkey,#opt.paire)
      end
    end
    for newkey,opt in pairs(mem.mem) do
      local bool=#newkey>1 and opt.type~=2
      local pair=opt.pair..opt.paire
      if bool and opt.keyconf.ft then
        bool=vim.tbl_contains(opt.keyconf.ft,vim.o.filetype)
      end
      if bool and mem.extensions.alpha and vim.tbl_contains(mem.extensions.alpha.conf.before or {},newkey) then
        bool=not o.line:sub(o.col-#pair-1,o.col-#pair-1):match('%a')
      end
      if bool and o.line:sub(o.col-#pair,o.col-1)==pair then
        return utils.delete(#pair)
      end
    end
  end
end
function M.ext.delete_pair(o)
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
function M.ext.delete_prev_pair(o)
  local prev_pair=mem.mem[o.prev_char]
  if prev_pair and prev_pair.type~=1 then
    local i=0
    local prev_2_char=o.line:sub(o.col-2-i,o.col-2-i)
    if o.conf.space then
      while prev_2_char==' ' do
        i=i+1
        prev_2_char=o.line:sub(o.col-2-i,o.col-2-i)
      end
    end
    if mem.ispair(prev_2_char,o.prev_char) then
      if prev_pair.type==3 then
        if not open_pair.open_pair_ambigous(o.prev_char,o.line) and i==0 then
          return utils.delete(2)
        end
      elseif not open_pair.open_paire_after(prev_2_char,o.prev_char,o.line,o.col) then
        return utils.moveh(2+i)..utils.delete(0,2+i)
      end
    end
  end
end
function M.ext.delete_overjump(o)
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
function M.ext.delete_space(o)
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
        return utils.moveh()..utils.delete(0,1)..utils.movel(matching_pair_pos-o.col-1)..utils.delete(0,1)..utils.moveh(matching_pair_pos-o.col-1)
      end
    end
  end
end
function M.ext.delete_multiline(o)
  if (not utils.incmd()) and o.line=='' then
    local prev_line=utils.getline(o.linenr-1)
    local next_line=utils.getline(o.linenr+1)
    if prev_line and next_line then
      local prev_char=prev_line:sub(-1,-1)
      local next_char=vim.fn.trim(next_line,' ',1):sub(1,1)
      if mem.ispair(prev_char,next_char) then
        return utils.delete(1,1+#next_line-#vim.fn.trim(next_line,' ',1))
      end
    end
  end
end
M.default_extensions={
  M.ext.delete_multichar,
  M.ext.delete_pair,
  M.ext.delete_prev_pair,
  M.ext.delete_overjump,
  M.ext.delete_space,
  M.ext.delete_multiline,
}
function M.backspace(conf,fallback)
  local o={}
  o.key=''
  o.conf=vim.tbl_extend('force',M.conf,conf or {})
  o.wline=utils.getline()
  o.wcol=utils.getcol()
  o.linenr=utils.getlinenr()
  o.line,o.col=o.wline,o.wcol
  mem.call_extension('string',o)
  o.prev_char=o.line:sub(o.col-1,o.col-1)
  o.next_char=o.line:sub(o.col,o.col)
  if not mem.call_extension('filetype',o) then
    if not mem.call_extension('cmdtype',o) then
      for _,i in ipairs(o.conf.extensions) do
        local ret=i(o)
        if ret then
          return ret
        end
      end
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
  local gconf=require'ultimate-autopair.config'.conf
  M.conf=gconf.bs or {}
  if M.conf.enable then
    vim.keymap.set('i','<bs>',M.create_backspace(),vim.tbl_extend('error',gconf.mapopt,{expr=true}))
    if gconf.cmap then
      vim.keymap.set('c','<bs>',M.create_backspace(),vim.tbl_extend('error',gconf.mapopt,{expr=true}))
    end
  end
end
return M
