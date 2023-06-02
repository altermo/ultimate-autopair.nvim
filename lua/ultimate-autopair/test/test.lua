local M={}
M.jobs={}
M.NUMBER_OF_JOBS=10
function M.info(msg)
    vim.notify(msg,vim.log.levels.INFO)
end
function M.error(msg)
    vim.notify(msg,vim.log.levels.ERROR)
end
function M.main()
    local file=vim.api.nvim_get_runtime_file('lua/ultimate-autopair/test/test.lua',false)[1]
    if vim.loader and vim.loader.enabled and _G.__FILE and _G.__FILE~=vim.loop.fs_stat(file).mtime.nsec then
        vim.ui.select({'Do nothing','Disable vim.loader'},
            {prompt='Can\'t run modified test while vim.loader is enabled'},
            function (choice)
            if choice=='Disable vim.loader' then
                vim.loader.disable()
                vim.cmd('luafile %')
            end
        end)
        return
    else
        _G.__FILE=vim.loop.fs_stat(file).mtime.nsec
    end
    M.path=vim.fn.fnamemodify(vim.api.nvim_get_runtime_file('lua/ultimate-autopair',false)[1],':h:h')
    M.count=0
    local rdps=vim.fn.system('grep -r --exclude=test.lua print '..M.path..'/lua')
    if rdps~='' then
        M.error('A rouge debug prin\t statement was spotted at '..rdps)
    end
    local rdft=vim.fn.system('find '..M.path..'/lua -type f ! -name "*.lua" ! -name "*.md" ! -name ".luarc.json"')
    if rdft~='' then
        M.error('A non lua file was spotted at '..rdft)
    end
    M.info('tests starting')
    for k,v in pairs(M) do
        if k:sub(1,5)=='test_' then
            v()
        end
    end
end
local function assert(x,y)
    if x~=y then
        M.error('Assertion failed '..vim.inspect(x)..' ~= '..vim.inspect(y))
    end
end
function M.stopall()
    for _,v in ipairs(M.jobs) do
        vim.fn.jobstop(v)
    end
    M.jobs={}
end
local function run(keys,match,conf)
    local tmp=vim.fn.tempname()
    local outtmp=vim.fn.tempname()
    vim.fn.writefile({
        ':set runtimepath+='..M.path,
        ':lua _G.DONTDEBUG=true',
        ':lua require"ultimate-autopair".setup('..vim.inspect(conf)..')',
        ':edit '..outtmp,
        keys..':wq!',
    },tmp)
    vim.wait(10000,function() return #M.jobs<M.count+M.NUMBER_OF_JOBS end)
    table.insert(M.jobs,vim.fn.jobstart({'nvim','-u','NONE','-i','NONE','-s',tmp},{
        on_exit=function()
            vim.fn.delete(tmp)
            assert(vim.fn.join(vim.fn.readfile(outtmp),'\n'),match)
            vim.fn.delete(outtmp)
            M.count=M.count+1
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
    run('I(()Xi(','(())')
    run('I"ab"hi"','"a""b"')
    run(':setf html\rI<!-A-','<!---->')
    run(':setf html\rI<!-A-xi-','<!---->')
    run(':setf html\rI-->I<!--','<!---->')
    run(':setf python\ri"""','""""""')
    run('I)I)','))')
    run('I())0a)','())')
end
function M.test_newline()
    run(':set cindent\rI{a\r','{\n\t\n}')
    run(':set cindent\rI{foo\r','{foo\n\t\n}')
    run(':set cindent\rI{foobi\r','{\n\tfoo\n}')
    run(':set cindent\rI{a\r','{\n\t\n}',{cr={autoclose=true}})
    --run(':set cindent\rI{fooa\r','{\n\t\n}',{cr={autoclose=true}})
    --run(':setf lua\rIdoA\r','do\n\nend',{cr={autoclose=true},{'do','end',imap=false,ft='lua'}})
    --run(':setf c\r:set cindent\rI{\r','{\n\t\n};') --TBD
    --run(':setf c\r:set cindent\rI{}i\r','{\n\t\n};') --TBD
    --run(':setf c\r:set cindent\rI{};hi\r','{\n\t\n};') --TBD
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
    --run(d..'I[ ]','') --TBD
    run(d..'I[foobi ','[foo]')
    run(d..':setf html\rI<!-A-','')
    run(d..':setf html\ri<!-a-A','')
    run(d..'i<!---->hhi','<!--->')
    run(d..'I"\'"\'\'i','"\'"')
    run(d..'I{\r','{}')
    run(d..':set cindent\rI{\rcc','{}')
    run(d..':set cindent\rI{\rcc','{}',{bs={indent_ignore=true}})
    run(d..'I[ ','[]')
    run(d..'I( foobi','(foo)')
    run(d..'I(  foobi','( foo )')
    run(d..'I(  a','(  )')
    run(d..'I(foobi','foo)',{bs={overjumps=false}})
    run(d..'I( ','( )',{bs={space=false}})
    run('(','',{bs={map={'<bs>','<C-h>'}}})
    run(d..'I"foo0a','foo',{{'"','"',bs_overjumps=true}})
    run(d..'I<a>\r','<><>',{{'<>','<>',newline=true}})
    run(d..'I<a< ','<<>>',{{'<<','>>',space=true}})
    run(d..'I<a< foobi','<<foo>>',{{'<<','>>',space=true}})
    run(d..'I$ ','$$',{{'$','$',space=true}})
end
function M.test_fastwarp()
    local d=':imap <C-e> <A-e>\r'
    local g=':imap <C-e> <A-E>\r'
    run(d..'I{}[hi','{[]}')
    run(d..'I{}foobhi','{foo}')
    run(d..'I{}foo,bhi','{foo},')
    run(d..'I{foo},barbhhi','{foo,bar}')
    run(d..'I()"bar"0a','("bar")')
    run(d..'I{foo},hi','{foo,}')
    run(d..'I{foo},(bar)bbi','{foo,}(bar)')
    run(d..'I{(),}hhi','{(,)}')
    run(d..'I\rki(','(\n)',{fastwarp={nocursormove=false}})
    run(d..'I(),""0a','(,)""')
    run(d..'I""[hi','"[]"')
    run(d..'I""foo0a','"foo"')
    run(d..'I""foo,0a','"foo",')
    run(d..'I"foo",bar0a','"foo,bar"')
    run(d..'I"foo",barbhhi','"foo,bar"')
    run(d..'I"" ""0a','" """')
    run(d..'O"foo"','"foo"\n')
    run(d..'IfooI<a<a','<<foo>>',{{'<<','>>',fastwarp=true}})
    run(d..'I()I<a<a','<<()>>',{{'<<','>>',fastwarp=true}})
    run(d..'I<a<I<a<a','<<<<>>>>',{{'<<','>>',fastwarp=true}})
    run(d..'I(<a<a','(<<>>)',{{'<<','>>',fastwarp=true}})
    run(d..'Ifoo,,I<a<a','<<foo>>,,',{{'<<','>>',fastwarp=true}})
    run(d..'I<a<I(','(<<>>)',{{'<<','>>'}})
    run(d..'IaøeI(','(aøe)')
    run(g..'I(foo)i','()foo')
    run(g..'I()i','()')
    run(g..'I(foo,bar)i','(foo),bar')
    run(g..'I({bar})i','(){bar}')
    run(g..'I("bar")i','()"bar"')
    run(g..'I(foo{bar}baz)i','(foo{bar})baz')
    run(g..'I(o)i','()\n')
    run(g..'I("",)0a','(""),')
    run(g..'I"foo"i','""foo')
    run(g..'I"foo"0a','""foo')
    run(g..'I""i','""')
    run(g..'I"foo,bar"i','"foo",bar')
    run(g..'I<a<fooa','<<>>foo',{{'<<','>>',fastwarp=true}})
    run(g..'I<a<()','<<>>()',{{'<<','>>',fastwarp=true}})
    run(g..'I<a<<a<hi','<<>><<>>',{{'<<','>>',fastwarp=true}})
    run(g..'I(<a<','(<<>>)',{{'<<','>>',fastwarp=true}})
end
function M.test_other_map()
    run('I[ ','[  ]')
    run('I[foobi ','[ foo ]')
    run('I[fooa bi ','[ foo ]')
    run('I[ foobi ','[  foo  ]')
    run('I[ foo','[ foo ]',{space={enable=false},space2={enable=true}})
    run('I[  foo','[  foo  ]',{space={enable=false},space2={enable=true}})
    run('Ioo]I[ f','[ foo ]',{space={enable=false},space2={enable=true}})
    run('Ioo ]I[ f','[ foo ]',{space={enable=false},space2={enable=true}})
    run('Ioo ]I[  f','[  foo  ]',{space={enable=false},space2={enable=true}})
    run(':setf markdown\rI+ [ ','+ [ ]')
    run('I<a<  |','<<  |  >>',{{'<<','>>',space=true}})
    run('I<a<foobi  ','<<  foo  >>',{{'<<','>>',space=true}})
    run('I$ |','$ | $',{{'$','$',space=true}})
    run('I$foobi ','$ foo $',{{'$','$',space=true}})
    run('I$ foo','$ foo $',{{'$','$',space=true},space={enable=false},space2={enable=true}})
    run('I<a< foo','<< foo >>',{{'<<','>>',space=true},space={enable=false},space2={enable=true}})
    --run('I(a','()') --TBD
    --run('I({a','({})') --TBD
    --run('I({(la','({()})') --TBD
    --run('I({)i','({})') --TBD
end
function M.test_extensions()
    run('I"foo"I(','("foo")')
    run('I"foo""bar"bhhi(','"foo()""bar"')
    run('I ")"0i(','() ")"')
    run('I"")0a(','"()")')
    run([[I"'xI']],[[''"'"]])
    run(':call setline(1,["foo\r','foo')
    run("Idona't","don't")
    run(':setf python\rIf\'','f\'\'')
    run('I"""','""""')
    run('I\\a(','\\(')
    run('I\\\\a(','\\\\()')
    run([[I'\\a"]],[['\\""']])
    run(":set lisp\rI'","'")
    run(':set lisp\rI"\'','"\'\'"')
    run(':set lisp\rI(','(',{extensions={rules={rules={{'not',{'option','lisp'}}}}}})
    run('I[{( ]$','[{(  )}]$')
    run('I(")$','("")$',{{'"','"',p=11,fly=true},extensions={fly={nofilter=true}}})
    run('I"("$','"()"$',{{'"','"',p=11,fly=true},extensions={fly={nofilter=true}}})
    run(':call setline(1,[input("\r(\r','(')
    run(':iab f foo\rIf()','foo()')
    run(':cab s setline\r:call s(1,["foo\r','foo')
    run('I\\)I(','()\\)')
    run([[I'""(a)]],[['""()']])
    run('I(")"','(")")')
    run('I"I(:setf lua\rla(','()("")',{extensions={suround=false,sub={p=200,ext={filetype={ft={'lua'},p=2},suround={p=1}}}}})
    run('I?a?I(','(??&&)',{{'??','&&',suround=true}})
    run('I({)','({)})',{extensions={fly={undomap='<C-b>'}}})
    ----TODO: test treesitter based extensions
end
function M.test_complex()
    local f=':imap <C-e> <A-e>\r'
    local F=':imap <C-a> <A-E>\r'
    run('Iprint("hello world!")','print("hello world!")')
    run('Iprint("hello world!','print("hello world!")')
    run(f..'Iprint "hello world!F ;s(','print("hello world!")')
    run(f..F..'Ifo\ro [bar]\r"baz"\rggI(','()fo\no [bar]\n"baz"\n',{fastwarp={nocursormove=false}})
    run(f..F..'Ifoo [bar]"baz"ggI(','()foo [bar]"baz"',{fastwarp={nocursormove=true}})
    run(f..F..'Ifoo [bar]"baz"ggI\'','\'\'foo [bar]"baz"',{fastwarp={nocursormove=false}})
end
function M.test_options()
    local b=':map! <C-h> <bs>\r'
    run('I(','(',{map=false})
    run('I(','(',{pair_map=false})
    run(b..':()Ia','',{cmap=false})
    run(b..':(<end>Ia','',{pair_cmap=false})
    run(b..'I()','(',{bs={enable=false}})
    run(b..'I()','(',{bs={map=false}})
    run('I()a','',{bs={map='a'}})
    run('I((ab','',{bs={map={'a','b'}}})
    run(b..':()Ia','',{bs={cmap=false}})
    run(b..'I(foobi','foo)',{bs={overjumps=false}})
    run(b..'I( ','( )',{bs={space=false}})
    run('I(\r','(\n)',{cr={enable=false}})
    run('I(A\r','(\n\n)',{cr={autoclose=true}})
    run('I( )','( )',{space={enable=false}})
    run('I( )','( )',{space={map=false}})
    run(':a\r( )\r.\r','( )',{space={cmap=false}})
    run(':setf lua\rI + [ ]',' + [ ]',{space={check_box_ft={'lua'}}})
    --TODO: write more tests
end
---@diagnostic disable-next-line: undefined-field
if not _G.DONTRUNTEST then
    M.main()
end
return M
