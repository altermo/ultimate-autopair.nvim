local prof=require'ultimate-autopair.prof_init'
local M={}
---@param confs prof.config[]
---@param mem core.module[]
function M.init(confs,mem)
    prof.init(confs,mem)
end
return M
