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
    keymap.set_mappings({
      i={
        ['(']={
          fallback=true,
          {
            action=pair.run_start,
            desc='autopairs start pair (,)',
            arg={'(',')'},
          }
        },
        [')']={
          fallback=true,
          {
            action=pair.run_end,
            desc='autopairs end pair (,)',
            arg={'(',')'},
          }
        }
      }
    },{})
  end
end

return M
