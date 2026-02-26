local keymap=require'ultimate-autopair.keymap'
local pair=require'ultimate-autopair.pair'

local M={}

---@param conf ua.config?
function M.setup(conf)
  if
    ---@diagnostic disable-next-line: unnecessary-if
    true then
    --TODO: temp
    assert(conf==nil)

    local tbl=vim.defaulttable(function() return {fallback=true} end)

    for _,p in ipairs{
      {'(',')'},
      {"'","'"},
      {'"','"'}} do
      local desc=('autopairs %%s pair %s,%s'):format(p[1],p[2])
      table.insert(tbl[p[2]],{
        action=pair.run_end,
        desc=desc:format'end',
        arg=p,
      })
      table.insert(tbl[p[1]],{
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
