local M={}
M.ext={}
M.exte={}
local mem=require'ultimate-autopair.memory'
local utils=require'ultimate-autopair.utils.utils'
local info_line=require'ultimate-autopair.utils.info_line'
function M.ext.fastwarp_over_pair(o)
  if mem.isstart(o.line,o.i) then
    if o.col+1==o.i then
      local pair=mem.mem[o.char]
      local matching_pair_pos
      if pair.type==3 then
        matching_pair_pos=info_line.findstringe(o.line,o.i+1,o.char)
      else
        matching_pair_pos=info_line.findepaire(o.line,o.i+1,o.char,pair.paire)
      end
      if matching_pair_pos then
        return utils.delete(0,1)..utils.movel(matching_pair_pos-o.col)..o.next_char..utils.moveh()
      end
    else
      return  utils.delete(0,1)..utils.movel(o.i-o.col-1)..o.next_char..utils.moveh()
    end
  end
end
function M.ext.fastwarp_over_word(o)
  local regex=vim.regex([[\w]])
  if o.conf.WORD then
    regex=vim.regex([[\S]])
  end
  if regex:match_str(o.char) then
    local j=o.i
    while regex:match_str(o.line:sub(j,j)) do
      j=j+1
    end
    return utils.delete(0,1)..utils.movel(j-o.col-1)..o.next_char..utils.moveh()
  end
end
function M.exte.fastwarp_end(o)
  if o.col~=#o.line then
    return utils.delete(0,1)..utils.movel(#o.line)..o.next_char..utils.moveh()
  end
end
function M.exte.fastwarp_next_line(o)
  if o.conf.multiline and o.col==#o.line and vim.fn.line('.')~=vim.fn.line('$') then
    return utils.delete(0,1)..'<down><home>'..o.next_char..utils.moveh()
  end
end
function M.ext.fastwarp_next_to_pair(o)
  if mem.isend(o.line,o.i) then
    if o.col+1==o.i then
      if o.conf.hopout then
        return
      else
        return ''
      end
    end
    return utils.delete(0,1)..utils.movel(o.i-o.col-1)..o.next_char..utils.moveh()
  end
end
M.default_extensions={
  M.ext.fastwarp_next_to_pair,
  M.ext.fastwarp_over_pair,
  M.ext.fastwarp_over_word,
}
M.default_endextensions={
  M.exte.fastwarp_end,
  M.exte.fastwarp_next_line,
}
function M.fastwarp(conf,fallback)
  local o={}
  o.conf=vim.tbl_extend('force',M.conf,conf or {})
  o.line=utils.getline()
  o.col=utils.getcol()
  o.next_char=o.line:sub(o.col,o.col)
  if mem.isend(o.line,o.col) then
    for i=o.col+1,#o.line do
      o.i=i
      o.char=o.line:sub(i,i)
      for _,v in pairs(o.conf.extensions) do
        local ret=v(o)
        if ret then
          return ret
        end
      end
    end
    for _,v in pairs(o.conf.endextensions) do
      local ret=v(o)
      if ret then
        return ret
      end
    end
  end
  if o.conf.fallback then
    return o.conf.fallback(fallback or '')
  else
    return fallback or ''
  end
end
function M.create_fastwarp(conf,key)
  return function ()
    return M.fastwarp(conf,key)
  end
end
function M.setup()
  local gconf=require'ultimate-autopair.config'.conf
  M.conf=gconf.fastwarp or {}
  if M.conf.enable then
    vim.keymap.set('i',M.conf.map,M.create_fastwarp(),vim.tbl_extend('error',gconf.mapopt,{expr=true}))
    if gconf.cmap and M.conf.cmap then
      vim.keymap.set('c',M.conf.cmap,M.create_fastwarp(),vim.tbl_extend('error',gconf.mapopt,{expr=true}))
    end
    if M.conf.Wmap then
      vim.keymap.set('i',M.conf.Wmap,M.create_fastwarp({WORD=true}),vim.tbl_extend('error',gconf.mapopt,{expr=true}))
      if gconf.cmap and M.conf.Wcmap then
        vim.keymap.set('c',M.conf.Wcmap,M.create_fastwarp({WORD=true}),vim.tbl_extend('error',gconf.mapopt,{expr=true}))
      end
    end
  end
end
return M
