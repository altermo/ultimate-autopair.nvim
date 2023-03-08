local M={}
local gconf=require'ultimate-autopair.config'.conf
M.conf=gconf.fastend or {}
local mem=require'ultimate-autopair.memory'
local utils=require'ultimate-autopair.utils.utils'
function M.fastend(fallback)
  local line=utils.getline()
  local col=utils.getcol()
  local next_char=line:sub(col,col)
  local next_pair=mem.mem[next_char]
  if next_pair and next_pair.type~=1 then
    if M.conf.smart and vim.tbl_contains({';',','},line:sub(-1,-1)) then
      return utils.delete(0,1)..'<end>'..utils.moveh()..next_char
    end
    return utils.delete(0,1)..'<end>'..next_char
  end
  if M.conf.fallback then
    return M.conf.fallback(fallback or '')
  else
    return fallback or ''
  end
end
function M.create_fastend(key)
  return function ()
    return M.fastend(key)
  end
end
function M.setup()
  if M.conf.enable then
    if not M.conf.nomap then
      vim.keymap.set('i',M.conf.map,M.create_fastend(),vim.tbl_extend('error',gconf.mapopt,{expr=true}))
    end
    if gconf.cmap and M.conf.cmap then
      vim.keymap.set('c',M.conf.cmap,M.create_fastend(),vim.tbl_extend('error',gconf.mapopt,{expr=true}))
    end
  end
end
return M
