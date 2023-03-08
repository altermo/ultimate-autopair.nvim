local M={}
local mem=require'ultimate-autopair.memory'
local utils=require'ultimate-autopair.utils.utils'
local info_line=require'ultimate-autopair.utils.info_line'
local open_pair=require'ultimate-autopair.utils.open_pair'
function M.fastclose(fallback)
  local o={}
  o.line=utils.getline()
  o.linenr=utils.getlinenr()
  o.col=utils.getcol()
  o.cmdmode=utils.incmd()
  o.key=''
  mem.call_extension('string',o)
  local ret=mem.load_extension('close').run(o.line,o.col,M.conf.pairs)
  if ret then return ret end
  if M.conf.fallback then
    return M.conf.fallback(fallback or '')
  else
    return fallback or ''
  end
end
function M.create_fastclose(key)
  return function ()
    return M.fastclose(key)
  end
end
function M.setup()
  if mem.extensions.close then
    local gconf=require'ultimate-autopair.config'.conf
    M.conf=mem.extensions.close.conf
    if M.conf.map then
      vim.keymap.set('i',M.conf.map,M.create_fastclose(),vim.tbl_extend('error',gconf.mapopt,{expr=true}))
      if gconf.cmap and M.conf.cmap then
        vim.keymap.set('c',M.conf.cmap,M.create_fastclose(),vim.tbl_extend('error',gconf.mapopt,{expr=true}))
      end
    end
  end
end
return M
