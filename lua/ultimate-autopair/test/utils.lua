local M={}
function M.ok(msg)
    vim.notify('Ok:'..msg,vim.log.levels.INFO)
end
function M.info(msg)
    vim.notify('Info:'..msg,vim.log.levels.INFO)
end
function M.error(msg)
    vim.notify('Err:'..msg,vim.log.levels.ERROR)
end
function M.warning(msg)
    vim.notify('Warn:'..msg,vim.log.levels.WARN)
end
return M
