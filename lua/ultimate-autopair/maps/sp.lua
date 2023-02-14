local M={}
local gconf=require'ultimate-autopair.config'.conf
M.conf=gconf.space or {}
local mem=require'ultimate-autopair.memory'
local utils=require'ultimate-autopair.utils.utils'
local info_line=require'ultimate-autopair.utils.info_line'
function M.space(fallback)
  local line=utils.getline()
  local col=utils.getcol()
  local prev_char
  local pcol=col
  for i=col-1,1,-1 do
    prev_char=line:sub(i,i)
    if prev_char~=' ' then
      pcol=i+1
      break
    end
  end
  local prev_pair=mem.mem[prev_char]
  if not M.conf.nomd and not utils.incmd() and vim.o.filetype=='markdown' and vim.regex([=[\v^\s*[+*-]|(\d+\.)\s+\[\]]=]):match_str(line:sub(1,col)) then
  elseif M.conf.notinstr and info_line.in_string(line,col,utils.getlinenr(),M.conf.notree) then
  elseif mem.extensions.cmdtype and vim.tbl_contains(mem.extensions.cmdtype.conf,vim.fn.getcmdtype()) then
  elseif prev_pair and prev_pair.type==1 then
    local matching_pair_pos=info_line.findepaire(line,pcol,prev_pair,prev_pair.paire)
    if matching_pair_pos then
      return ' '..utils.addafter(matching_pair_pos-col,' ')
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
    vim.keymap.set('i',' ',M.create_space(),vim.tbl_extend('error',gconf.mapopt,{expr=true}))
    if gconf.cmap then
      vim.keymap.set('c',' ',M.create_space(),vim.tbl_extend('error',gconf.mapopt,{expr=true}))
    end
  end
end
return M
