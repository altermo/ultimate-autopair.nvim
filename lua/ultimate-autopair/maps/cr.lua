local M={}
M.extensions={}
local gconf=require'ultimate-autopair.config'.conf
M.conf=gconf.cr or {}
local utils=require'ultimate-autopair.utils.utils'
local mem=require'ultimate-autopair.memory'
function M.extensions.newline_multichar(o)
  if M.conf.multichar then
    for ft,list_of_pairs in pairs(M.conf.multichar) do
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
  if M.conf.autoclose and o.prev_pair and o.prev_pair.type==1 and o.col-1==#o.line then
    return '\r'..o.prev_pair.paire..o.semi..'<up><end>\r'
  end
end
function M.newline(fallback)
  local o={}
  o.line=utils.getline()
  o.col=utils.getcol()
  o.prev_char=o.line:sub(o.col-1,o.col-1)
  o.next_char=o.line:sub(o.col,o.col)
  o.prev_pair=mem.mem[o.prev_char]
  o.semi=''
  if vim.tbl_contains(M.conf.addsemi or {},vim.o.filetype) and not utils.incmd() then
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
  if M.conf.fallback then
    return M.conf.fallback(fallback or '\x1d\r')
  else
    return fallback or '\x1d\r'
  end
end
function M.cmpnewline()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(M.newline(),true,true,true),'n',true)
end
function M.create_newline(key)
  return function ()
    return M.newline(key)
  end
end
function M.setup()
  if M.conf.enable then
    vim.keymap.set('i','<cr>',M.create_newline(),vim.tbl_extend('error',gconf.mapopt,{expr=true}))
  end
end
return M
