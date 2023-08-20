local M={}
local rep=500
M.file1={
    ('('):rep(rep),
    (')'):rep(rep),
}
M.file2=vim.fn["repeat"]({'(',')'},rep)
M.file3=vim.list_extend(vim.fn["repeat"]({'('},rep),vim.fn["repeat"]({')'},rep))
M.file4={('"()";'):rep(rep)}
function M.create_act_and_file(act,filecont,fn,path)
    local source=vim.fn.tempname()
    local file=vim.fn.tempname()
    vim.fn.writefile({
        'vim.opt.runtimepath:append("'..path..'")',
        '_G.UA_DEBUG_DONT=true',
        'require("ultimate-autopair").setup()',
        'local acts=[==['..act..']==]',
        'vim.cmd.edit{"'..file..'"}',
        'vim.treesitter.start(0,"lua")',
        'vim.cmd.norm{acts}',
        'vim.cmd.write{bang=true}',
        'vim.cmd.quit{bang=true}',
    },source)
    vim.fn.writefile(filecont,file)
    local err,msg=pcall(fn,source)
    vim.fn.delete(source)
    vim.fn.delete(file)
    if not err then error(msg) end
end
function M.timeit(filecont,act,path)
    local ts1=vim.fn.reltime()
    local err
    M.create_act_and_file('',filecont,function (source)
        if vim.system({'nvim','--clean','-l',source}):wait(10000).signal~=0 then
            err='timeout'
        end
    end,path)
    local t1=vim.fn.reltimefloat(vim.fn.reltime(ts1))
    local ts2=vim.fn.reltime()
    M.create_act_and_file(act,filecont,function (source)
        if vim.system({'nvim','--clean','-l',source}):wait(10000).signal~=0 then
            err='timeout'
        end
    end,path)
    local t2=vim.fn.reltimefloat(vim.fn.reltime(ts2))
    if err then
        M.log(tostring(err))
    else
        M.log(tostring(t2-t1))
    end
end
function M.start()
    M.log=vim.lg or vim.notify
    local path=vim.fn.fnamemodify(vim.api.nvim_get_runtime_file('lua/ultimate-autopair',false)[1],':h:h')
    if not vim.fn.has('nvim-0.10.0') then
        error('Timeit requires neovim >= 0.10.0')
    end
    M.timeit(M.file1,'Go(',path)
    M.timeit(M.file2,'Go(',path)
    M.timeit(M.file3,'Go(',path)
    M.timeit(M.file4,'Go(',path)
end
M.start()
return M
