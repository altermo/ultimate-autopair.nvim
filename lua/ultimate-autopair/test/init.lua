local M={}
M.fn={
    ok=function (msg)
        vim.notify('Ok:'..msg,vim.log.levels.INFO)
    end,
    info=function (msg)
        vim.notify('Info:'..msg,vim.log.levels.INFO)
    end,
    error=function (msg)
        vim.notify('Err:'..msg,vim.log.levels.ERROR)
    end,
    warning=function (msg)
        vim.notify('Warn:'..msg,vim.log.levels.WARN)
    end,
}
function M.get_paths()
    local path=vim.api.nvim_get_runtime_file('lua/ultimate-autopair',false)[1]
    return{
        path=path,
        root=vim.fn.fnamemodify(path,':h:h'),
    }
end
function M.check_not_alowed_files_and_strings(paths)
    local function handle_stdout(_,data,_)
        for _,v in ipairs(data) do
            if v~='' then
                M.fn.warning('Found something not allowed: '..v:sub(v:sub(2):find(' ') or 1))
            end
        end
    end
    if not (vim.fn.executable('grep') and vim.fn.executable('find')) then
        M.fn.warning('Some of the required executables are missing for dev testing')
        M.fn.info('INFO Pleas make sure that find and grep are installed')
        return
    end
    local string_check_print=vim.fn.jobstart({
        'grep','-r','--exclude-dir=test','print',paths.path,
    },{on_stdout=handle_stdout})
    local string_check_log=vim.fn.jobstart({
        'grep','-r','--exclude-dir=test','vim.lg',paths.path,
    },{on_stdout=handle_stdout})
    local file_check=vim.fn.jobstart({
        'find',paths.path,'-type','f','!','-name','*.lua','!','-name','*.md'
    },{on_stdout=handle_stdout})
    if vim.tbl_contains(vim.fn.jobwait({file_check,string_check_log,string_check_print},5000),-1) then
        vim.fn.jobstop(file_check)
        vim.fn.jobstop(string_check_log)
        vim.fn.jobstop(string_check_print)
        M.fn.warning('timeout: could not run all string/file checks,') return
    end
end
function M.check_other(_)
    if vim.fn.has('nvim-0.9.0')==0 then
        M.fn.warning('You have an older version of neovim than recommended')
    end
    ---@diagnostic disable-next-line: undefined-field
    if _G.UA_DEBUG_DONT then
        M.fn.info('UA_DEBUG_DONT is set: no debugging will happen')
    end
    if not pcall(require,'nvim-treesitter') then
        M.fn.warning('nvim-treesitter not installed: most of treesitter spesific behavior will not work')
    end
end
function M.start()
    local paths=M.get_paths()
    ---@diagnostic disable-next-line: undefined-field
    if _G.UA_DEV then
        M.check_not_alowed_files_and_strings(paths)
    end
    M.check_other(paths)
    M.start_test_runner_and_test(paths)
end
function M.start_test_runner_and_test(paths)
    local source=vim.fn.tempname()
    local outfile=vim.fn.tempname()
    vim.fn.writefile({
        'vim.opt.runtimepath:append("'..paths.root..'")',
        '_G.UA_DEBUG_DONT=true',
        ---@diagnostic disable-next-line: undefined-field
        '_G.UA_DEV='..vim.inspect(_G.UA_DEV),
        '_G.UA_IN_TEST=true',
        'require("ultimate-autopair.test.run").run("'..outfile..'")',
    },source)
    local job=vim.fn.jobstart({'nvim','--clean','-l',source})
    --Maybe:
    ---multiple instances (per category?)
    ---use tcp server for out instead of file
    local jobstat=vim.fn.jobwait({job},10000)[1]
    if jobstat==-1 then
        M.fn.warning('timeout: tester process did not exit')
    elseif jobstat~=0 then
        M.fn.warning('job exited with code '..jobstat)
    end
    vim.fn.jobstop(job)
    M.parse_out(vim.fn.readfile(outfile))
    vim.fn.delete(source)
    vim.fn.delete(outfile)
end
function M.parse_out(out)
    if #out==0 then
        M.fn.info('No output was generated from test runner')
    end
    for _,v in ipairs(out) do
        local code,msg=unpack(vim.split(v,'´'))
        if code=='OK' then
            M.fn.ok(msg)
        elseif code=='ERR' then
            M.fn.error(msg)
        elseif code=='INFO' then
            M.fn.info(msg)
        elseif code=='WARN' then
            M.fn.warning(msg)
        end
    end
end
---@diagnostic disable-next-line: undefined-field
if _G.UA_TEST_NOW then
    M.start()
end
return M
