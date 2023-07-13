local config=require 'ultimate-autopair.config'
local M={}
function M.init_conf(conf,mem)
    for _,v in ipairs(conf) do
        config.init_conf(v,mem)
    end
end
return M
