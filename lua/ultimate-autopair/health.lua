---@diagnostic disable: duplicate-set-field
local M={}
local ok=vim.health.ok or vim.health.report_ok
local info=vim.health.info or vim.health.report_info
local warn=vim.health.warn or vim.health.report_warn
local error=vim.health.error or vim.health.report_error
local start=vim.health.start or vim.health.report_start
function M.check()
    local stat,out=pcall(function()
        start('ultimate-autopair')
        package.loaded['ultimate-autopair.test']=nil
        package.loaded['ultimate-autopair.test.test']=nil
        package.loaded['ultimate-autopair.test.run']=nil
        local stat,test=pcall(require,'ultimate-autopair.test')
        if not stat then
            error('could not open test.lua: '..test)
            return
        end
        test.fn.ok=ok
        test.fn.error=error
        test.fn.warning=warn
        test.fn.info=info
        test.start()
    end)
    if not stat then
        error(('error while checking health: %s'):format(out))
    end
end
return M
