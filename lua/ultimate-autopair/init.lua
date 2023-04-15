local config=require'ultimate-autopair.config'
local default=require'ultimate-autopair.default'
local M={}
function M.add_conf(conf)
    config.add_conf(conf)
end
function M.setup(conf)
    M.add_conf(vim.tbl_deep_extend('force',default.conf,conf or {}))
    M.init()
end
function M.init()
    config.init()
end
return M
