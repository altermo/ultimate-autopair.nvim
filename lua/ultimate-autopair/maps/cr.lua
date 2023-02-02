local M={}
local gconf=require'ultimate-autopair.config'.conf
local conf=gconf.cr or {}
local utils=require'ultimate-autopair.utils.utils'
local mem=require'ultimate-autopair.memory'
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
  elseif conf.autoclose and prev_pair and col-1==#line then
    utils.appendline('',{indent=indent+indentsize,cursor='last'})
    utils.appendline(prev_pair.paire,{indent=indent})
    return
  elseif conf.multichar then
    for k,i in pairs(conf.multichar) do
      if vim.o.filetype==k then
        for _,v in ipairs(i) do
          local offset=0
          if v.pair or v.next then
            offset=#v[2]
          end
          local bool=true
          if v.next and bool then
            bool=line:sub(-#v[2])==v[2]
          elseif bool then
            bool=line:sub(-#v[1]-offset,-offset-1)==v[1]
          end
          if bool and not v.noalpha then
            bool=v.noalpha or not line:sub(-#v[1]-1-offset,-#v[1]-1-offset):match('%a')
          end
          if bool then
            if v.pair or v.next then
              utils.setline(line:sub(0,-offset-1))
            end
            utils.appendline('',{indent=indent+indentsize,cursor='last'})
            utils.appendline(v[2],{indent=indent})
            return
          end
        end
      end
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
