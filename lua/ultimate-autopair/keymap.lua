local util=require'ultimate-autopair.util'
local context=require'ultimate-autopair.util.context'

local M={}

---@class ua.keymap.list.entry
---@field run fun(con: ua.context, arg: any): string?
---@field arg any
---@field desc string

---@class ua.keymap.list
---@field [number] ua.keymap.list.entry
---@field fallback string|true|fun():string

---@alias ua.keymap.table table<ua.mode,table<string,ua.keymap.list>>

---@type {[number]:[ua.mode,string,ua.keymap.list],top_conf:table}
local mapped

local function clear_mapped()
  for _,map in ipairs(mapped or {}) do
    local mode=map[1]=='v' and 'x' or map[1]
    local key=map[2] --[[@as string]]

    if vim.startswith(vim.fn.maparg(key,mode),"v:lua.require'ultimate-autopair.keymap") then
      vim.keymap.del(mode,key)
    end
  end

  mapped=nil --[[@as any]]
end

---@param keymap_tbl ua.keymap.table
---@param top_conf ua.iconfig
function M.set_mappings(keymap_tbl,top_conf)
  clear_mapped()

  mapped={top_conf=top_conf}

  for mode,maps in pairs(keymap_tbl) do
    for key,list in pairs(maps) do
      if key:find'\0' then
        error('Null byte found in keymap lhs, mapping this crashes neovim')
      end

      local desc={}
      for _,entry in ipairs(list) do
        table.insert(desc,entry.desc)
      end

      local id=#mapped+1

      vim.keymap.set(mode=='v' and 'x' or mode,
      key,
      ("v:lua.require'ultimate-autopair.keymap'._run(%d)"):format(id),
      {noremap=true,
      expr=true,replace_keycodes=false,
      desc=table.concat(desc,'\n\t\t ')})
      mapped[id]={mode,key,list}
    end
  end
end

---@param str string
---@return string
local function add_abbrev_expand(str)
    if str:sub(1,1)=='\r' then
        return '\x1d'..str
    elseif vim.regex('^[^[:keyword:][:cntrl:]\x80]'):match_str(str) then
        return '\x1d'..str
    end
    return str
end

---@param id number
---@return string
local function run(id)
  local map=assert(mapped[id] --[[@as any?]])

  local con=context.create_context(mapped)
  for _,item in ipairs(map[3]) do
    local ret=item.run(con,item.arg)
    if ret then
      return ret
    end
  end

  local fallback=map[3].fallback
  return type(fallback)=='function' and fallback()
  or fallback==true and util.keycode(map[2])
  or assert(fallback) --[[@as string]]
end

---@param id number
---@return string
function M._run(id)
  return add_abbrev_expand(run(id))
end

return M
