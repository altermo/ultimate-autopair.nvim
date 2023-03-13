local M={}
local gconf=require'ultimate-autopair.config'.conf
M.conf=gconf.space or {}
local mem=require'ultimate-autopair.memory'
local utils=require'ultimate-autopair.utils.utils'
local info_line=require'ultimate-autopair.utils.info_line'
function M.space(fallback)
  local o={}
  o.key=''
  o.linenr=utils.getlinenr()
  o.line=utils.getline()
  o.col=utils.getcol()
  local prev_char
  local pcol=o.col
  mem.call_extension('string',o)
  for i=o.col-1,1,-1 do
    prev_char=o.line:sub(i,i)
    if prev_char~=' ' then
      pcol=i+1
      break
    end
  end
  local prev_pair=mem.mem[prev_char]
  if mem.extensions.filetype and vim.tbl_contains(mem.extensions.filetype.conf or {},vim.o.filetype) then
  elseif not M.conf.nomd and not utils.incmd() and vim.o.filetype=='markdown' and vim.regex([=[\v^\s*[+*-]|(\d+\.)\s+\[\]]=]):match_str(o.line:sub(1,o.col)) then
  elseif M.conf.notinstr and info_line.in_string(o.line,o.col,utils.getlinenr(),M.conf.notree) then
  elseif mem.extensions.cmdtype and vim.tbl_contains(mem.extensions.cmdtype.conf,vim.fn.getcmdtype()) then
  elseif prev_pair and prev_pair.type==1 then
    local matching_pair_pos=info_line.findepaire(o.line,pcol,prev_char,prev_pair.paire)
    if matching_pair_pos then
      return ' '..utils.addafter(matching_pair_pos-o.col,' ')
    end
  end
  if M.conf.fallback then
    return M.conf.fallback(fallback or '\x1d ')
  else
    return fallback or '\x1d '
  end
end
function M.create_space(key)
  return function ()
    return M.space(key)
  end
end
function M.setup()
  if M.conf.enable then
    if not M.conf.nomap then
      vim.keymap.set('i',' ',M.create_space(),vim.tbl_extend('error',gconf.mapopt,{expr=true}))
    end
    if gconf.cmap then
      vim.keymap.set('c',' ',M.create_space(),vim.tbl_extend('error',gconf.mapopt,{expr=true}))
    end
  end
end
return M
