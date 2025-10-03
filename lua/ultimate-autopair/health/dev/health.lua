local health=require'ultimate-autopair.health'
local M={}
function M.check()
    health.start(true,health.health_handler)
end
return M
