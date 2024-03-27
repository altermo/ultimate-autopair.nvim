---@diagnostic disable: duplicate-set-field
local M={}
local ok=vim.health.ok or vim.health.report_ok
local info=vim.health.info or vim.health.report_info
local warn=vim.health.warn or vim.health.report_warn
local error=vim.health.error or vim.health.report_error
local start=vim.health.start or vim.health.report_start
function M.check()
    start('ultimate-autopair')
    package.loaded['ultimate-autopair.test']=nil
    package.loaded['ultimate-autopair.test.utils']=nil
    package.loaded['ultimate-autopair.test.test']=nil
    package.loaded['ultimate-autopair.test.run']=nil
    local utils=require'ultimate-autopair.test.utils'
    utils.ok=ok
    utils.error=error
    utils.warning=warn
    utils.info=info
    require('ultimate-autopair.test').start()
end
return M
