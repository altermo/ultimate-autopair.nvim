local M={}
local gconf=require'ultimate-autopair.config'.conf
local conf=gconf.cr or {}
local utils=require'ultimate-autopair.utils.utils'
local mem=require'ultimate-autopair.memory'
local function newline_multichar(line,indent,indentsize)
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
          if pair.pair or pair.next then
            utils.setline(line:sub(0,-offset-1))
          else
            --TODO: check if current indent block contains paire, then return
          end
          utils.appendline('',{indent=indent+indentsize,cursor='last'})
          utils.appendline(pair[2],{indent=indent})
          return true
        end
      end
    end
  end
end
function M.newline()
  local line=utils.getline()
  local col=utils.getcol()
  local prev_char=line:sub(col-1,col-1)
  local next_char=line:sub(col,col)
  local prev_pair=mem.mem[prev_char]
  local next_pair=mem.mem[next_char]
  local linenr=utils.getlinenr()
  local indent=utils.getindent(linenr)
  local indentsize=utils.getindentsize()
  if prev_pair and next_pair and prev_pair.paire==next_char and next_pair.pair==prev_char and col==#line then
    utils.setline(utils.getline():sub(1,-2))
    utils.appendline('',{indent=indent+indentsize,cursor='last'})
    utils.appendline(next_char,{indent=indent})
    return
  elseif conf.autoclose and prev_pair and prev_pair.type==1 and col-1==#line then
    utils.appendline('',{indent=indent+indentsize,cursor='last'})
    utils.appendline(prev_pair.paire,{indent=indent})
    return
  elseif conf.multichar then
    if newline_multichar(line,indent,indentsize) then
      return
    end
  end
  if type(conf.fallback)=='function' then
    conf.fallback()
  else
    vim.api.nvim_feedkeys(conf.fallback or '\r','n',true)
  end
end
function M.setup()
  if conf.enable then
    vim.keymap.set('i','<cr>',M.newline,gconf.mapopt)
  end
end
return M
