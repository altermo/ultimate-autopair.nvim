local M={}
--TODO: create timeit for long files
M.file_empty={''}
M.file1={
    ('('):rep(500),
    (')'):rep(500),
}
function M.create_act_and_file(act,filecont,fn,path)
    local source=vim.fn.tempname()
    local file=vim.fn.tempname()
    vim.fn.writefile({
        'vim.opt.runtimepath:append("'..path..'")',
        '_G.UA_DEBUG_DONT=true',
        'require("ultimate-autopair").setup()',
        'local acts=[==['..act..':x!\r'..']==]',
        'local it=vim.iter(vim.split(acrs,""))',
        'function fn()',
        '   local next=it:next()',
        '   if not next ther return end',
        '   vim.cmd.norm{next,bang=true}',
        '   vim.schedule(fn)',
        'end',
        'fn()',
    },source)
    vim.fn.writefile(filecont,file)
    local err,msg=pcall(fn,source,file)
    vim.fn.delete(source)
    --vim.fn.delete(file)
    if not err then error(msg) end
end
function M.timeit(filecont,act,path)
    local t=os.clock()
    local err
    M.create_act_and_file(act,filecont,function (source,file)
        if vim.system({'nvim','--clean','-l',source,file}):wait(10000).signal~=0 then
            err='timeout'
        end
    end,path)
    if err then
        vim.notify(tostring(err))
    else
        vim.notify(tostring(os.clock()-t))
    end
end
function M.start()
    local path=vim.fn.fnamemodify(vim.api.nvim_get_runtime_file('lua/ultimate-autopair',false)[1],':h:h')
    if not vim.fn.has('nvim-0.10.0') then
        error('Timeit requires neovim >= 0.10.0')
    end
    M.timeit(M.file_empty,'A(',path)
    M.timeit(M.file1,':setf lua\r|Go(',path)
end
M.start()
return M
