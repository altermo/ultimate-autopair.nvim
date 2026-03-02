local util=require'util'

---@class ua.filter.alpha.conf
---@field before boolean|string?
---@field after boolean|string?

---@param con ua.context
---@param range Range4
---@param after boolean
---@param chars string|true
---@return boolean
local function is_keywordy(con,range,after,chars)
  local char
  if after then
    char=util.chars_after_range(con,range,1)
  else
    char=util.chars_before_range(con,range,1)
  end
  if char=='\0' then
    return false
  elseif type(chars)=='string' then
    return chars:find(char,1,true) and true or false
  end
  error'TODO'
  -- local ft=util.get_filetype(con,range)
  --
  -- -- not `con.root_filetype` because of cmdline
  -- if ft==vim.o.filetype then
  --   return vim.fn.charclass(char)==2
  -- end
  -- return util.with({o={
  --   iskeyword=util.ft_get_opt(con,ft,'iskeyword'),
  --   lisp=util.ft_get_opt(con,ft,'lisp'),
  -- }},function ()
  --   return vim.fn.charclass(char)==2
  -- end)
end


---@type ua.ifilter<ua.filter.alpha.conf>
return {
  once='iter_pos',
  iter_pos=function(con,range,conf)
    if conf.foo then
      return conf
    end
    if conf.after
      and is_keywordy(con,range,true,conf.after) then
      return true
    end
    if conf.before
      and is_keywordy(con,range,false,conf.before) then
      return true
    end
    return false
  end,
  _name='alpha',
}
