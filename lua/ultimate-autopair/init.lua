local keymap=require'ultimate-autopair.keymap'
local pair=require'ultimate-autopair.pair'
local utf=require'ultimate-autopair.util.utf'

local M={}

---@param conf ua.config?
function M.setup(conf)
  if
    ---@diagnostic disable-next-line: unnecessary-if
    true then
    --TODO: temp

    local tbl=vim.defaulttable(function() return {fallback=true} end)

    conf=conf or {}
    vim.list_extend(conf,{
      {'(',')'},
      {"'","'"},
      {'"','"'}})

    for _,p in ipairs(conf) do
      local desc=('autopairs %%s pair %s,%s'):format(p[1],p[2])
      p[1]=utf.new(p[1])
      p[2]=utf.new(p[2])
      table.insert(tbl[utf.sub(p[2],1,1)],{
        action=pair.run_end,
        desc=desc:format'end',
        arg=p,
      })
      table.insert(tbl[utf.sub(p[1],-1)],{
        action=pair.run_start,
        desc=desc:format'start',
        arg=p,
      })
    end

    keymap.set_mappings({
      i=tbl
    },{})
  end
end

return M
