local M={}

function M.start()
    local uatutor_path=unpack(vim.api.nvim_get_runtime_file('tutor/ultimate-autopair.uatutor',false))

    if not uatutor_path then
        error'Could not find tutor/ultimate-autopair.uatutor in runtimepath'
    end

    vim.cmd.edit(uatutor_path)
    vim.bo.buftype='nofile'

    --TODO
end

return M
