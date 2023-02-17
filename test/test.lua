local M={}
M.jobs={}
local function error(msg)
    vim.notify(msg,'error')
end
function M.main()
    M.path=vim.fn.fnamemodify('..',':p')
    local rdps=vim.fn.system('grep -r print '..M.path..'/lua')
    if rdps~='' then
        error('A rouge debug print statement was spotted at '..rdps)
    end
    local rdft=vim.fn.system('find '..M.path..'/lua -type f ! -name "*.lua"')
    if rdft~='' then
        error('A non lua file was spotted at '..rdft)
    end
    vim.notify('tests starting')
    for k,v in pairs(M) do
        if k:sub(1,5)=='test_' then
            v()
        end
    end
end
local function assert(x,y)
    if x~=y then
        error('Assertion failed '..vim.inspect(x)..' ~= '..vim.inspect(y))
    end
end
local function run(keys,match,conf)
    local tmp=vim.fn.tempname()
    local outtmp=vim.fn.tempname()
    vim.fn.writefile({
        ':set runtimepath+='..M.path,
        ':lua require"ultimate-autopair".setup('..vim.inspect(conf)..')',
        ':edit '..outtmp,
        keys..':wq!',
    },tmp)
    table.insert(M.jobs,vim.fn.jobstart({'nvim','-u','NONE','-i','NONE','-s',tmp},{
        on_exit=function()
            vim.fn.delete(tmp)
            assert(vim.fn.join(vim.fn.readfile(outtmp),'\n'),match)
            vim.fn.delete(outtmp)
        end,pty=true
    }))
end
function M.test_simple()
    run('I(','()')
    run('a(..','((()))')
    run('3a(','((()))')
    run('Ifoo0R(','()o')
    run('I(','()')
    run('I"','""')
    run('I""','""')
    run('I()','()')
    run('I(()xi)','(())')
    run('I"ab"hi"','"a""b"')
end
function M.test_newline()
    run(':set cindent\rI{\r','{\n\t\n}')
    run(':set cindent\rI{foo\r','{foo\n\t\n}')
    run(':set cindent\rI{foobi\r','{\n\tfoo\n}')
    run(':set cindent\rI{a\r','{\n\t\n}',{cr={autoclose=true}})
    run(':setf c\r:set cindent\rI{\r','{\n\t\n};')
    run(':setf c\r:set cindent\rI{}i\r','{\n\t\n};')
    run(':setf c\r:set cindent\rI{};hi\r','{\n\t\n};')
    run(':setf lua\rIdoA\r','do\n\nend',{cr={multichar={enable=true}}})
    run(':setf markdown\rI```\r','```\n\n```')
end
function M.test_backspace()
    local d=':imap <C-h> <bs>\r'
    run(d..'I[','')
    run(d..'I"','')
    run(d..'I[]','')
    run(d..'I[[','[]')
    run(d..'I[[lxi','[]')
    run(d..'I[foobi','foo')
    run(d..'I[ ','[]')
    run(d..'I[ ]','')
    run(d..'I[foobi ','[foo]')
    run(d..':setf c\rI/A*','')
    run(d..':setf c\ri/a*A','')
    run(d..'I"\'"\'\'i','"\'"')
    run(d..'I{\r','{}')
end
function M.test_other_map()
    local d=':imap <C-e> <A-e>\r'
    local e=':imap <C-o> <A-$>\r'
    local f=':imap <C-h> <A-C-e>\r'
    local g=':imap <C-e> <A-E>\r'
    run('I[ ','[  ]')
    run('I[foobi ','[ foo ]')
    run(':setf markdown\rI+ [ ','+ [ ]')
    run(d..'I{}[hi','{[]}')
    run(d..'I{}foobhi','{foo}')
    run(d..'I{}foo,bhi','{foo},')
    run(d..'I{foo},barbhhi','{foo,bar}')
    run(d..'I()"bar"0a','("bar")')
    run(d..'I{foo},hi','{foo,}')
    run(d..'I{foo},(bar)bbi','{foo,}(bar)')
    run(d..'I{(),}hhi','{(,)}')
    run(d..'I\rki(','(\n)')
    run(e..'Ifoo,barI(','(foo,bar)')
    run(e..'Ifoo,bar,I(','(foo,bar),',{fastend={smart=true}})
    run(f..'Ifoo,bar ,I(','(foo,bar) ,')
    run(g..'I(foo)i','()foo')
    run(g..'I()i','()')
    run(g..'I(foo,bar)i','(foo),bar')
    run(g..'I({bar})i','(){bar}')
    run(g..'I("bar")i','()"bar"')
    run(g..'I(foo{bar}baz)i','(foo{bar})baz')
    run(g..'I(o)i','()\n')
end
function M.test_extensions()
    run(':setf c\ri/a*','/**/')
    run('I"foo"I(','("foo")')
    run('I ")"0i(','() ")"')
    run(':call setline(1,["foo\r','foo')
    run("Idona't","don't")
    run(':setf python\rIf\'','f\'\'')
    run('I\\a(','\\(')
    run('I\\\\a(','\\\\()')
    run([[I'\\a"]],[['\\""']])
    run(":set lisp\rI'","'")
    run(':set lisp\rI"\'','"\'\'"')
    run('I[{( ]$','[{(  )}]$')
    run('I(foo) ,0a)$','(foo)$ ,',{extensions={{'fly',{match='\\w'}}}})
    run(':call setline(1,[input("\r(\r','(')
    run(':iab f foo\rIf()','foo()')
    run(':cab s setline\r:call s(1,["foo\r','foo')
    --TODO: test treesitter based extensions
end
---@diagnostic disable-next-line: undefined-global
if not DONTRUNTEST then
    M.main()
end
return M
