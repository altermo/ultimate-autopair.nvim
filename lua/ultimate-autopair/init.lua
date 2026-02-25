local keymap=require'ultimate-autopair.keymap'

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
            action=function ()
              return {'()',{'h',1}}
            end,
            desc='autopairs pair (,)',
            config={},
          }
        }
      }
    },{})
  end
end

return M
