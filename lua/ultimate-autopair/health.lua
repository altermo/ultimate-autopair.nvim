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
    local stat,out=pcall(function()
        _G.DONTRUNTEST=true
        start('ultimate-autopair')
        _G.__FILE=nil
        local stat,test=pcall(require,'ultimate-autopair.test.test')
        if not stat then
            error('could not find test.lua: aborting')
            return
        end
        ---@diagnostic disable-next-line: duplicate-set-field
        test.info=function (msg)
            info(msg)
        end
        ---@diagnostic disable-next-line: duplicate-set-field
        test.error=function (msg)
            error(('A test failed: %s'):format(msg))
        end
        test.main()
        local _,ret=vim.wait(2000,function() return test.count==#test.jobs end)
        if ret then
            warn('could not run all tests in time')
        else
            ok('all tests finnished')
        end
    end)
    _G.__FILE=save.__FILE
    _G.DONTRUNTEST=save.DONTRUNTEST
    if not stat then
        error(('error while checking health: %s'):format(out))
    end
end
return M
