local M={}
local rep=500
M.file1={
    ('('):rep(rep),
    (')'):rep(rep),
}
M.file2=vim.fn["repeat"]({'(',')'},rep)
M.file3=vim.list_extend(vim.fn["repeat"]({'('},rep),vim.fn["repeat"]({')'},rep))
M.file4={('"()";'):rep(rep)}
M.file5=vim.fn["repeat"]({('a'):rep(80)..';'},rep)
M.file6=vim.fn["repeat"]({'"'..('a'):rep(80)..'";'},rep)
M.file7=vim.fn["repeat"]({'('..('a'):rep(80)..');'},rep)
function M.create_act_and_file(act,filecont,fn,path,conf)
    local source=vim.fn.tempname()
    local file=vim.fn.tempname()
    local out=vim.fn.tempname()
    vim.fn.writefile({
        'vim.opt.runtimepath:append("'..path..'")',
        '_G.UA_DEBUG_DONT=true',
        'require("ultimate-autopair").setup('..vim.inspect(conf or {},{newline=''})..')',
        'local acts=[==['..act..']==]',
        'vim.cmd.edit{"'..file..'"}',
        'vim.treesitter.start(0,"lua")',
        'local t=vim.fn.reltime()',
        'vim.cmd.norm{acts}',
        'vim.fn.writefile({tostring(vim.fn.reltimefloat(vim.fn.reltime(t)))},"'..out..'")',
        'vim.cmd.write{bang=true}',
        'vim.cmd.quit{bang=true}',
    },source)
    vim.fn.writefile(filecont,file)
    local err,msg=pcall(fn,source)
    vim.fn.delete(source)
    vim.fn.delete(file)
    local s,ret=pcall(vim.fn.readfile,out)
    vim.fn.delete(out)
    if not err then error(msg) end
    return s and ret[1] or nil
end
function M.timeit(filecont,act,path,conf)
    local err
    local t=M.create_act_and_file(act,filecont,function (source)
        if vim.system({'nvim','--clean','-l',source}):wait(10000).signal~=0 then
            err='timeout'
        end
    end,path,conf)
    if err then
        M.log(tostring(err))
    else
        M.log(vim.inspect(t))
    end
end
function M.start()
    M.log=vim.lg or vim.notify
    local path=vim.fn.fnamemodify(vim.api.nvim_get_runtime_file('lua/ultimate-autopair',false)[1],':h:h')
    if not vim.fn.has('nvim-0.10.0') then
        error('Timeit requires neovim >= 0.10.0')
    end
    M.timeit(M.file1,'ggO(',path)
    M.timeit(M.file2,'ggO(',path)
    M.timeit(M.file3,'ggO(',path)
    M.timeit(M.file4,'ggO(',path)
    M.timeit(M.file5,'ggO(',path)
    M.timeit(M.file7,'ggO(',path)
    M.timeit(M.file5,'Go()',path)
    M.timeit(M.file7,'Go()',path)
    M.timeit(M.file5,'Go"',path,{config_internal_pairs={{'"','"',multiline=true}}})
    M.timeit(M.file6,'Go"',path,{config_internal_pairs={{'"','"',multiline=true}}})
end
M.start()
return M
