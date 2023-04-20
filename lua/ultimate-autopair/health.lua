local ok=vim.health.ok or vim.health.report_ok
local warn=vim.health.warn or vim.health.report_warn
local info=vim.health.info or vim.health.report_info
local error=vim.health.error or vim.health.report_error
local start=vim.health.start or vim.health.report_start
local M={}
M.check=function ()
    local save={}
    save.__FILE=_G.__FILE
    save.DONTRUNTEST=_G.DONTRUNTEST
    local stat=pcall(function()
        _G.DONTRUNTEST=true
        start('ultimate-autopair')
        _G.__FILE=nil
        local stat,test=pcall(require,'ultimate-autopair.test.test')
        if not stat then
            warn('could not find test.lua: aborting')
            return
        end
        ok('found test.lua')
        ---@diagnostic disable-next-line: duplicate-set-field
        test.info=function (msg)
            info(msg)
        end
        ---@diagnostic disable-next-line: duplicate-set-field
        test.error=function (msg)
            error(('A test failed: %s'):format(msg))
        end
        test.main()
    end)
    _G.__FILE=save.__FILE
    _G.DONTRUNTEST=save.DONTRUNTEST
    if not stat then
        error('error while checking health')
    end
end
return M
