local keymap=require'ultimate-autopair.keymap'
local pair=require'ultimate-autopair.pair'
local utf=require'ultimate-autopair.util.utf'
local util=require'ultimate-autopair.util'
local backspace=require'ultimate-autopair.map.backspace'

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
      {"'","'",start_pair_filter={require'ultimate-autopair.filter.alpha',{before=true}}},
      {'"','"'}})

    local pairs_={}
    for _,p in ipairs(conf) do
      p.start_pair_filter={require'ultimate-autopair.filter'.multi_or,{
        p.start_pair_filter
      }}
      p.end_pair_filter={require'ultimate-autopair.filter'.multi_or,{
        p.end_pair_filter
      }}
      for _,f in ipairs{
        {require'ultimate-autopair.filter.escape'}
      } do
        table.insert(p.start_pair_filter[2],f)
        table.insert(p.end_pair_filter[2],f)
      end

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
      table.insert(pairs_,p)
    end
    table.insert(tbl['<bs>'],{
      action=backspace.run,
      desc='autopairs backspace',
      arg={pairs=pairs_},
    })

    keymap.set_mappings({
      i=tbl
    },{})
  end
end

return M
