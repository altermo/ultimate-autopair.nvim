local M={}
local gconf=require'ultimate-autopair.config'.conf
M.conf=gconf.fastwarp or {}
M.endextensions={}
local mem=require'ultimate-autopair.memory'
local utils=require'ultimate-autopair.utils.utils'
local info_line=require'ultimate-autopair.utils.info_line'
M.extensions={
  function (o)
    if mem.isend(o.line,o.col-o.i-1) and o.i==0 then
      local pair=mem.mem[o.char]
      local matching_pair_pos
      if pair.type==3 then
        matching_pair_pos=info_line.findstring(o.line,o.col-o.i-1,o.char)
      else
        matching_pair_pos=info_line.findpair(o.line,o.col-o.i-1,pair.pair,o.char)
      end
      if matching_pair_pos then
        return utils.delete(0,1)..utils.moveh(o.col-matching_pair_pos)..o.next_char..utils.moveh()
      end
    end
  end,
  function (o)
    if mem.isend(o.line,o.col-o.i-1) and o.i~=0 then
        return utils.delete(0,1)..utils.moveh(o.i)..o.next_char..utils.moveh()
    end
  end,
  function (o)
    local prev_n_pair=mem.mem[o.char]
    if prev_n_pair and prev_n_pair.paire==o.next_char and prev_n_pair.type==1 then
      if o.i==0 then
        if o.conf.hopout then
          return utils.delete(0,1)..utils.moveh(1)..o.next_char..utils.moveh()
        else
          return ''
        end
      else
        return utils.delete(0,1)..utils.moveh(o.i)..o.next_char..utils.moveh()
      end
    end
  end,
  function (o)
    local prev_char=o.line:sub(o.col-o.i-2,o.col-o.i-2)
    if prev_char and vim.regex([[\w]]):match_str(prev_char) and not vim.regex([[\w]]):match_str(o.char) then
      return utils.delete(0,1)..utils.moveh(o.i+1)..o.next_char..utils.moveh()
    end
  end,
}
function M.endextensions.rfastwarp_prev_line(o)
  if o.conf.multiline and vim.fn.line('.')~=0 then
    if o.col==1 then
      return utils.delete(0,1)..'<up><end>'..o.next_char..utils.moveh()
    else
      return utils.delete(0,1)..'<home><C-v>'..o.next_char..utils.moveh()
    end
  end
end
function M.rfastwarp(conf,fallback)
  local o={}
  o.conf=vim.tbl_extend('force',M.conf,conf or {})
  o.line=utils.getline()
  o.col=utils.getcol()
  o.next_char=o.line:sub(o.col,o.col)
  if mem.isend(o.line,o.col) then
    for i=0,o.col-2 do
      o.i=i
      o.char=o.line:sub(o.col-i-1,o.col-i-1)
      for _,v in pairs(M.extensions) do
        local ret=v(o)
        if ret then
          return ret
        end
      end
    end
    for _,v in pairs(M.endextensions) do
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
function M.create_rfastwarp(conf,key)
  return function ()
    return M.rfastwarp(conf,key)
  end
end
function M.setup()
  if M.conf.enable then
    vim.keymap.set('i',M.conf.rmap,M.create_rfastwarp(),vim.tbl_extend('error',gconf.mapopt,{expr=true}))
    if gconf.cmap and M.conf.rcmap then
      vim.keymap.set('c',M.conf.rcmap,M.create_rfastwarp(),vim.tbl_extend('error',gconf.mapopt,{expr=true}))
    end
  end
end
return M
