local M={}
local gconf=require'ultimate-autopair.config'.conf
M.conf=gconf.cr or {}
local utils=require'ultimate-autopair.utils.utils'
local mem=require'ultimate-autopair.memory'
local function newline_multichar(line)
  for ft,list_of_pairs in pairs(M.conf.multichar) do
    if vim.o.filetype==ft then
      for _,pair in ipairs(list_of_pairs) do
        local offset=0
        if pair.pair or pair.next then
          offset=#pair[2]
        end
        local bool=true
        if pair.next and bool then
          bool=line:sub(-#pair[2])==pair[2]
        elseif bool then
          bool=line:sub(-#pair[1]-offset,-offset-1)==pair[1]
        end
        if bool and not pair.noalpha then
          bool=not line:sub(-#pair[1]-1-offset,-#pair[1]-1-offset):match('%a')
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
function M.newline(fallback)
  local line=utils.getline()
  local col=utils.getcol()
  local prev_char=line:sub(col-1,col-1)
  local next_char=line:sub(col,col)
  local prev_pair=mem.mem[prev_char]
  local semi=''
  if vim.tbl_contains(M.conf.addsemi or {},vim.o.filetype) and not utils.incmd() then
    if prev_char=='{' and col-1==#line or col==#line then
      if col+1==#line and line:sub(col+1,col+1)==';' then
        line=line:sub(0,-2)
      else
        semi=';'
      end
    end
  end
  local key
  if mem.ispair(prev_char,next_char) then
    key='\r<end>'..semi..'<up><end>\r'
  elseif M.conf.autoclose and prev_pair and prev_pair.type==1 and col-1==#line then
    key='\r'..prev_pair.paire..semi..'<up><end>\r'
  elseif M.conf.multichar then
    key=newline_multichar(line)
  end
  if key then
    return key
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
