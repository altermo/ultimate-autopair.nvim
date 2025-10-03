local health=require'ultimate-autopair.health'
local M={}
function M.check()
    package.loaded['ultimate-autopair.test']=nil
    local test=require'ultimate-autopair.test'
    test.run_tests(nil,health.health_handler)
end
return M
