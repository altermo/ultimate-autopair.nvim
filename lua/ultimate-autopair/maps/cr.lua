local M={}
M.extensions={}
local gconf=require'ultimate-autopair.config'.conf
local info_line=require'ultimate-autopair.utils.info_line'
M.conf=gconf.cr or {}
local utils=require'ultimate-autopair.utils.utils'
local mem=require'ultimate-autopair.memory'
function M.extensions.newline_multichar(o)
  if o.conf.multichar then
    for ft,list_of_pairs in pairs(o.conf.multichar) do
      if vim.o.filetype==ft then
        for _,pair in ipairs(list_of_pairs) do
          local offset=0
          if pair.pair or pair.next then
            offset=#pair[2]
          end
          local bool=true
          if pair.next and bool then
            bool=o.line:sub(-#pair[2])==pair[2]
          elseif bool then
            bool=o.line:sub(-#pair[1]-offset,-offset-1)==pair[1]
          end
          if bool and not pair.noalpha then
            bool=not o.line:sub(-#pair[1]-1-offset,-#pair[1]-1-offset):match('%a')
          end
          if bool and not (pair.pair or pair.next) then
            bool=not (vim.trim(utils.getline(o.linenr+1) or '')==pair[2] and vim.fn.indent(o.linenr)==vim.fn.indent(o.linenr+1))
          end
          if bool then
            local ret=''
            if pair.pair or pair.next then
              ret=ret..utils.delete(0,offset)
            end
            return ret..'\r'..pair[2]..'<up><end>\r'
          end
        end
      end
    end
  end
end
function M.extensions.normal_newline(o)
  if mem.ispair(o.prev_char,o.next_char) then
    return '\r<end>'..o.semi..'<up><end>\r'
  end
end
function M.extensions.close_newline(o)
  if o.conf.autoclose and o.prev_pair and o.prev_pair.type==1 and o.col-1==#o.line and
    vim.fn.trim(utils.getline(o.linenr+1) or '',' ',1):sub(1,1)~=o.prev_pair.paire then
    return '\r'..o.prev_pair.paire..o.semi..'<up><end>\r'
  end
end
function M.extensions.after_pair_newline(o)
  local next_pair=mem.mem[o.next_char]
  if o.prev_pair and not next_pair and o.prev_pair.type==1 then
    local matching_pair_pos=info_line.findepaire(o.line,o.col,o.prev_char,o.prev_pair.paire)
    if matching_pair_pos then
      return utils.movel(matching_pair_pos-o.col)..'\r<up><home>'..utils.movel(o.col-1)..'\r'
    end
  end
end
function M.extensions.before_paire_newline(o)
  local next_pair=mem.mem[o.next_char]
  if next_pair and not o.prev_pair and next_pair.type==2 and o.col==#o.line and info_line.findpair(o.line,o.col,next_pair.pair,o.next_char) then
    return '\r'..o.semi..'<up><end>\r'
  end
end
function M.newline(conf,fallback)
  local o={}
  o.conf=vim.tbl_extend('force',M.conf,conf or {})
  o.line=utils.getline()
  o.linenr=utils.getlinenr()
  o.col=utils.getcol()
  o.prev_char=o.line:sub(o.col-1,o.col-1)
  o.next_char=o.line:sub(o.col,o.col)
  o.prev_pair=mem.mem[o.prev_char]
  o.semi=''
  if vim.tbl_contains(o.conf.addsemi or {},vim.o.filetype) and not utils.incmd() then
    if o.prev_char=='{' and o.col-1==#o.line or o.col==#o.line then
      if o.col+1==#o.line and o.line:sub(o.col+1,o.col+1)==';' then
        o.line=o.line:sub(0,-2)
      else
        o.semi=';'
      end
    end
  end
  for _,i in pairs(M.extensions) do
    local ret=i(o)
    if ret then
      return '\x1d'..ret
    end
  end
  if o.conf.fallback then
    return o.conf.fallback(fallback or '\x1d\r')
  else
    return fallback or '\x1d\r'
  end
end
function M.cmpnewline()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(M.newline(),true,true,true),'n',true)
end
function M.create_newline(conf,key)
  return function ()
    return M.newline(conf,key)
  end
end
function M.setup()
  if M.conf.enable then
    vim.keymap.set('i','<cr>',M.create_newline(),vim.tbl_extend('error',gconf.mapopt,{expr=true}))
  end
end
return M
