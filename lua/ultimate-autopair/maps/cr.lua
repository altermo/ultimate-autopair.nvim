local M={}
local gconf=require'ultimate-autopair.config'.conf
local conf=gconf.cr or {}
local utils=require'ultimate-autopair.utils.utils'
local mem=require'ultimate-autopair.memory'
local function newline_multichar(line)
  for ft,list_of_pairs in pairs(conf.multichar) do
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
          bool=pair.noalpha or not line:sub(-#pair[1]-1-offset,-#pair[1]-1-offset):match('%a')
        end
        if bool then
          local ret=''
          if pair.pair or pair.next then
            ret=ret..utils.delete(0,offset)
          end
          return ret..'\r\r'..pair[2]..'<up><C-o>"_cc'
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
  local next_pair=mem.mem[next_char]
  local key
  if prev_pair and next_pair and prev_pair.paire==next_char and next_pair.pair==prev_char and col==#line then
    key=utils.delete(0,1)..'\r\r'..next_char..'<up><C-o>"_cc'
  elseif conf.autoclose and prev_pair and prev_pair.type==1 and col-1==#line then
    key='\r\r'..prev_pair.paire..'<up><C-o>"_cc'
    return
  elseif conf.multichar then
    key=newline_multichar(line)
  end
  if key then
    return key
  end
  if conf.fallback then
    return conf.fallback(fallback or '\x1d\r')
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
  if conf.enable then
    vim.keymap.set('i','<cr>',M.create_newline(),vim.tbl_extend('error',gconf.mapopt,{expr=true}))
  end
end
return M
