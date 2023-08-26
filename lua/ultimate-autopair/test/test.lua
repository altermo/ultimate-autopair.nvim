return {
    simple={
        {'|','(','(|)'},
        {'(|)',')','()|'},
        {'|','"','"|"'},
        {'"|"','"','""|'},
        {'() |','(','() (|)'},
        {"'' |","'","'' '|'"},
        {'(|))','(','((|))'},
        {'"a|b"','"','"a"|"b"'},
        {'<!-|','-','<!--|-->',{ft='html'}},
        {'<!-|-->','-','<!--|-->',{ft='html'}},
        {'""|','"','"""|"""',{ft='python'}},
        {'|)',')',')|)'},
        {'(|))',')','()|)'},
        {'f|','(','foo(|)',{abbr={f='foo'}}},
        {'(|)',')','()|)',{c={config_internal_pairs={{'(',')',disable_end=true}}}}},
        {'|','(','(|)',{c={config_internal_pairs={{'(',')',disable_end=true}}}}},
        {'|','(','(|',{c={config_internal_pairs={{'(',')',disable_start=true}}}}},
        {'(|)',')','()|',{c={config_internal_pairs={{'(',')',disable_start=true}}}}},
        {'|','"','"|',{c={config_internal_pairs={{'"','"',disable_start=true}}}}},
        {'"|"','"','""|""',{c={config_internal_pairs={{'"','"',disable_end=true}}}}},
    },
    SKIP_interactive={
        {'|','a(..','(((|)))',{interactive=true}},
        {'|','3a(','(((|)))',{interactive=true}},
        {'|foo','R(','()o',{interactive=true}},
        {'|','I="("\r','()',{interactive=true,c={extensions={cmdtype={skip={}}}}}},
        --TODO: test treesitter inside cmdline
        {'|','Iprint("hello world!")','print("hello world!")|',{interactive=true}},
        {'|','Iprint("hello world!','print("hello world!|")',{interactive=true}},
        {'|','Iprint "hello world!F ;s(','print(|"hello world!")',{interactive=true}},
        {'|','Ifo\ro [bar]\r"baz"\rggI(','(|)fo\no [bar]\n"baz"\n',{interactive=true,c={fastwarp={nocursormove=false}}}},
        {'|','Ifo\ro [bar]\r"baz"\rggI(','(|)fo\no [bar]\n"baz"\n',{interactive=true,c={fastwarp={nocursormove=true}}}},
        {'|','Ifoo [bar]"baz"ggI\'','\'|\'foo [bar]"baz"',{interactive=true,c={fastwarp={nocursormove=false}}}},
        {'|','I"("','"()"|',{interactive=true,c={extensions={fly={nofilter=true}},config_internal_pairs={{'"','"',fly=true}}}}},
        {'|','I{I(','(|{})',{interactive=true,c={config_internal_pairs={{'{','}',suround=true}}}}},
        {'|',"Iprint'hello world!)'I('","('')print'hello world!)'",{interactive=true}}
    },
    newline={
        {'{|}','\r','{\n|\n}'},
        {'{foo|}','\r','{foo\n|\n}'},
        {'{|foo}','\r','{\n|foo\n}',},
        {'local x=[[|]]','\r','local x=[[\n|\n]]',{ft='lua'}},
        {'"""|"""','\r','"""\n|\n"""',{ft='python'}},
        {'```lua|```','\r','```lua\n|\n```',{ft='markdown',skip=true}},
        {'{|','\r','{\n|\n}',{c={cr={autoclose=true}}}},
        {'{[(|','\r','{[(\n|\n)]}',{c={cr={autoclose=true}}}},
        {'({|\n)','\r','({\n|\n}\n)',{c={cr={autoclose=true}}}},
        {'{foo|','\r','{foo\n|\n}',{c={cr={autoclose=true}}}},
        {'{|foo','\r','{\n|foo\n}',{c={cr={autoclose=true}}}},
        {'```|','\r','```\n|\n```',{c={cr={autoclose=true}},ft='markdown'}},
        {'do|','\r','do\n\nend',{skip=true,ft='lua',c={cr={autoclose=true},{'do','end',imap=false}}}},
        {'{|}','\r','{\n|\n};',{skip=true,ft='c',c={autosemi={'c'}}}},
        {'{|','\r','{\n|\n};',{skip=true,ft='c',c={autosemi={'c'},autoclose=true}}},
        {'{|};','\r','{\n|\n};',{skip=true,ft='c',c={autosemi={'c'},autoclose=true}}},
    },
    backspace={
        {'[|]','','|'},
        {'"|"','','|'},
        {'""|','','|'},
        {'" "|" "','','" | "'},
        {'[]|','','|'},
        {'[[|]]','','[|]'},
        {'[[|]','','[|]'},
        {'[|foo]','','|foo'},
        {'[|\n]','','|\n'},
        {'[ ]|','','|',{skip=true}},
        {'[ |foo ]','','[|foo]',},
        {'(|)','H','|',{c={bs={map={'<bs>','H'}}}}},
        {'<!--|-->','','|',{ft='html'}},
        {'<!---->|','','|',{ft='html'}},
        {'<!--|-->','','<!-|-->'},
        {[["'"'|']],'',[["'"|]],{ts=true}},
        {'{\n|\n}','','{|}'},
        {'{\n\t|\n}','','{|}',{interactive=true}},
        {'{\n\t|\n}','','{|}',{c={bs={indent_ignore=true}}}},
        {'[ | ]','','[|]'},
        {'( |foo )','','(|foo)'},
        {'(  |foo  )','','( |foo )'},
        {'(  | )','','( | )'},
        {'(|foo)','','|foo)',{c={bs={overjumps=false}}}},
        {'( | )','','(| )',{c={bs={space=false}}}},
        {'"|foo"','','|foo',{c={config_internal_pairs={{'"','"',bs_overjumps=true}}}}},
        {'"|\n"','','|\n',{c={config_internal_pairs={{'"','"',bs_overjumps=true,multiline=true}}}}},
        {'<>\n|\n<>','','<>|<>',{c={{'<>','<>',newline=true}}}},
        {'<>\n\t|\n<>','','<>|<>',{c={{'<>','<>',newline=true},bs={indent_ignore=true}}}},
        {'<< | >>','','<<|>>',{c={{'<<','>>',space=true}}}},
        {'<< |foo >>','','<<|foo>>',{c={{'<<','>>',space=true}}}},
        {'$ | $','','$|$',{c={{'$','$',space=true}}}},
        {'( |  )','','( | )',{c={bs={space='balance'}}}},
        {'(  |)','','(|)',{c={bs={space='balance'}}}},
        {'( |foo  )','','( |foo )',{c={bs={space='balance'}}}},
        {'(  |foo )','','( |foo )',{c={bs={space='balance'}}}},
        {'f|','','|',{abrv={f='foo'}}},
        {'<!--|-->','','<!-|',{c={bs={single_delete=true}},ft='html'}},
        {'```|```','','``|',{c={bs={single_delete=true}},ft='markdown'}},
    },
    fastwarp={
        {'{|}[]','','{|[]}'},
        {'{|}foo','','{|foo}'},
        {'{|}foo,','','{|foo},'},
        {'{foo|},bar','','{foo,bar|}'},
        {'(|)"bar"','','(|"bar")'},
        {'{foo|},','','{foo,|}'},
        {'{foo|},(bar)','','{foo,|}(bar)'},
        {'{(|),}','','{(|,)}'},
        {'{(|,)}','','{(|,)}'},
        {'(|)\n','','(\n|)',{c={fastwarp={nocursormove=false}}}},
        {'(|),""','','(|,)""',{ts=true}},
        {'"|"[],','','"|[]",',{ts=true}},
        {'("|")','','("|")',{ts=true}},
        {'"|"foo','','"|foo"',{ts=true}},
        {'"|"foo,','','"|foo",',{ts=true}},
        {'"|foo",bar','','"|foo,bar"',{ts=true}},
        {'"foo|",bar','','"foo,bar|"',{ts=true}},
        {'"|" ""','','"| """',{ts=true}},
        {'"foo|"\n','','"foo|"\n',{ts=true}},
        {'<<|>>foo','','<<|foo>>',{c={{'<<','>>',fastwarp=true}}}},
        {'<<|>>()','','<<|()>>',{c={{'<<','>>',fastwarp=true}}}},
        {'<<|>><<>>','','<<|<<>>>>',{c={{'<<','>>',fastwarp=true}}}},
        {'(<<|>>)','','(<<|>>)',{c={{'<<','>>',fastwarp=true}}}},
        {'<<|>>foo,,','','<<|foo>>,,',{c={{'<<','>>',fastwarp=true}}}},
        {'(|)<<>>','','(|<<>>)',{c={{'<<','>>'}}}},
        {'<>|<>foo','','<>|foo<>',{c={{'<>','<>',fastwarp=true}}}},
        {'<>|<>()','','<>|()<>',{c={{'<>','<>',fastwarp=true}}}},
        {'<>|<><><>','','<>|<><><>',{c={{'<>','<>',fastwarp=true}}}},
        {'(<>|<>)','','(<>|<>)',{c={{'<>','<>',fastwarp=true}}}},
        {'<>|<>foo,,','','<>|foo<>,,',{c={{'<>','<>',fastwarp=true}}}},
        {'(|)<><>','','(|<><>)',{c={{'<>','<>'}}}},
        {'```|```lua','','```|lua```',{ft='markdown'}},
        {'(|)a_e','','(|a_e)'},
        {'(|")")foo','','(|")"foo)',{c={fastwarp={no_filter_nodes={}}},ts=true}},
        {'(|)foo','e','(|foo)',{c={fastwarp={multi=true,{map='e'},{map='E',nocursormove=false}}}}},
        {'(|)foo','E','(foo|)',{c={fastwarp={multi=true,{map='e'},{map='E',nocursormove=false}}}}},
        {'(|),','','(|,)',{c={fastwarp={faster=true}}}},
        {'(|),{},','','(|,{}),',{c={fastwarp={faster=true}}}},
        {'{|},foo(""),','','{|,foo("")},',{c={fastwarp={faster=true}}}},
    },
    rfaswarp={
        {'(foo|)','','(|)foo'},
        {'(|foo)','','(|)foo'},
        {'(|)','','(|)'},
        {'(foo,bar|)','','(foo|),bar'},
        {'({bar}|)','','(|){bar}'},
        {'("bar"|)','','(|)"bar"',{ts=true}},
        {'(foo{bar}baz|)','','(foo{bar}|)baz'},
        {'(\n|)','','(|)\n'},
        {'(\n,|)','','(\n|),'},
        {'(|"",)','','(|""),',{ts=true}},
        {'"foo|"','','"|"foo',{ts=true}},
        {'"|foo"','','"|"foo',{ts=true}},
        {'"|"','','"|"',{ts=true}},
        {'"foo,bar|"','','"foo|",bar'},
        {'<<foo|>>','','<<|>>foo',{c={{'<<','>>',fastwarp=true}}}},
        {'<<()|>>','','<<|>>()',{c={{'<<','>>',fastwarp=true}}}},
        {'<<|<<>>>>','','<<|>><<>>',{c={{'<<','>>',fastwarp=true}}}},
        {'(<<|>>)','','(<<|>>)',{c={{'<<','>>',fastwarp=true}}}},
        {'(|"")','','(|)""'},
        {'(|")")','','(|)")"',{ts=true,c={fastwarp={filter_string=true}}}},
        {'(|{)}','','(|){}',{c={fastwarp={hopout=true}}}},
    },
    space={
        {'[|]',' ','[ | ]'},
        {'[|foo]',' ','[ |foo ]'},
        {'[|foo ]',' ','[ |foo ]'},
        {'[ |foo]',' ','[  |foo  ]'},
        {'+ [|]',' ','+ [ |]',{ft='markdown'}},
        {'+ [ ](|)',' ','+ [ ]( | )',{ft='markdown'}},
        {'<<|>>',' ','<< | >>',{c={{'<<','>>',space=true}}}},
        {'<< | >>',' ','<<  |  >>',{c={{'<<','>>',space=true}}}},
        {'<<|foo>>',' ','<< |foo >>',{c={{'<<','>>',space=true}}}},
        {'<< |foo >>',' ','<<  |foo  >>',{c={{'<<','>>',space=true}}}},
        {'$|$',' ','$ | $',{c={{'$','$',space=true}}}},
        {'$|foo$',' ','$ |foo $',{c={{'$','$',space=true}}}},
        {'|','I="( \r','( | )',{interactive=true}},
    },
    space2={
        {'[ |]','foo','[ foo| ]',{interactive=true,c={space2={enable=true}}}},
        {'[  |','foo','[  foo|  ]',{interactive=true,c={space2={enable=true}}}},
        {'[ |oo]','f','[ f|oo ]',{interactive=true,c={space2={enable=true}}}},
        {'[ |oo ]','f','[ f|oo ]',{interactive=true,c={space2={enable=true}}}},
        {'[  |oo ]','f','[  f|oo  ]',{interactive=true,c={space2={enable=true}}}},
        {'$ |$','foo','$ foo| $',{interactive=true,c={{'$','$',space=true},space2={enable=true}}}},
        {'<< |>>','foo','<< foo| >>',{interactive=true,c={{'<<','>>',space=true},space2={enable=true}}}},
    },
    close={
        {'(|','','(|)'},
        {'({|','','({|})'},
        {'({[|}','','({[|]}'},
        {'({()|','','({()|})'},
        {'({|)','','({|})'},
        {'"|','','"|"',{ts=true}},
        {'""|','','""|',{ts=true}},
        {'("|','','("|")',{ts=true}},
        {'("|")','','("|")',{ts=true}},
        {'<!--|','','<!--|-->',{ft='html'}},
        {'<!--|-->','','<!--|-->',{ft='html'}},
        {'<!---->|','','<!---->|',{ft='html'}},
    },
    tabout={
        {'(|{})','','({}|)',{c={tabout={enable=true}}}},
        {'(|"")','','(""|)',{c={tabout={enable=true}}}},
        {'"|()"','','"()|"',{c={tabout={enable=true}}}},
        {'(|)','','()|',{c={tabout={enable=true,hopout=true}}}},
        {'"|"','','""|',{c={tabout={enable=true,hopout=true}}}},
        {'(|)','','(|)',{c={tabout={enable=true}}}},
        {'<!--|,-->','','<!--,|-->',{ft='html',c={tabout={enable=true}}}},
        {'<!--,|-->','','<!--,-->|',{ft='html',c={tabout={enable=true,hopout=true}}}},
    },
    ext_suround={
        {'|"foo"','(','(|"foo")'},
        {'|""','(','(|"")'},
        {'"foo|""bar"','(','"foo(|)""bar"'},
        {'|?&','(','(|?&)',{c={{'?','&',suround=true}}}},
        {'|??&&','(','(|??&&)',{c={{'??','&&',suround=true}}}},
        {'|"")','(','(|"")'},
        {'<|""','<','<<|"">>',{c={{'<<','>>',dosuround=true}}}},
        {'|""','<','<|""',{c={{'<<','>>',dosuround=true}}}},
        {'<|"">>','<','<<|"">>',{c={{'<<','>>',dosuround=true}}}},
        {'|")"','(','(|")")',{ts=true}},
    },
    ext_cmdtype={
        {'|','I="("\r','()',{interactive=true,c={extensions={cmdtype={skip={}}}}}},
        {'|','I="("\r','(',{interactive=true,c={extensions={cmdtype={skip={'='}}}}}},
        {'|','(','(|)',{incmd=':'}},
        {'|','(','(|',{incmd='/'}},
    },
    ext_alpha={
        {"don|t","'","don'|t"},
        {"'a|'","'","'a'|"},
        {"f|","'","f'|'",{ft='python'}},
        {"fr|","'","fr'|'",{ft='python'}},
        {"a' |","'","a' '|'",{c={extensions={alpha={filter=true}}}}},
        {'a" |','"','a" "|',{c={extensions={alpha={filter={'txt'}}}}}},
        {"a' |","'","a' '|'",{ft='txt',c={extensions={alpha={filter={'txt'}}}}}},
        {'|a','<','<|a',{c={{'<','>',alpha_after=true}}}},
        {'a|','<','a<|',{c={{'<','>',alpha=true}}}},
        {'a<|','<','a<<|',{c={{'<<','>>',alpha=true}}}},
        {'<|a','<','<<|a',{c={{'<<','>>',alpha_after=true}}}},
        {'b""|','"','b"""|"',{ft='python',c={config_internal_pairs={{'"""','"""',alpha=true}}}}},
    },
    ext_filetype={
        {'<!-|','-','<!--|'},
        {'""|','"','"""|"'},
        {'<!-|','-','<!--|-->',{ft='html'}},
        {'|','(','(|',{ft='TelescopePrompt'}},
    },
    ext_escape={
        {'\\|','(','\\(|'},
        {'\\\\|','(','\\\\(|)'},
        {[['\\|']],'"',[['\\"|"']]},
        {'|\\)','(','(|)\\)'},
        {'\\(|)',')','\\()|)'},
        {'\\<!-|','-','\\<!--|',{ft='html'}},
        {'<!--\\-->|-->','-','<!--\\-->-->|',{ft='html'}},
        {'\\|','(','\\(|\\)',{c={{'\\(','\\)'}}}},
        {'\\\\|','(','\\\\(|)',{c={{'\\(','\\)'}}}},
        {'\\(|\\)','\\','\\(\\)|',{c={{'\\(','\\)'}}}},
        {'\\(|)','','\\|)'},
    },
    ext_cond={
        {'|',"'","'|",{ft='fennel'}},
        {'"|"',"'",[["'|'"]],{ts=true,ft='fennel',tsft='lua'}},
        {'|','(','(|',{c={extensions={cond={cond=function () return false end}}}}},
        {'#|','(','#(|',{c={extensions={cond={cond=function (_,o) return o.line:sub(o.col-1,o.col-1)~='#' end}}}}},
        {'|#)','(','(|)#)',{c={extensions={cond={cond=function (_,o)
            return o.line:sub(o.col-1,o.col-1)~='#' end,filter=true}}}}},
        {'"|"','(','"(|"',{ts=true,c={extensions={cond={cond=function(fns) return not fns.in_string() end}}}}},
        --{'--|','(','--(|',{ft='lua',ts=true,{c={extensions={tsnode={p=50,outside={'comment'}}}}}}}, --TODO
        --{'|','(','(|)',{ft='lua',ts=true,{c={extensions={tsnode={p=50,outside={'comment'}}}}}}},
        --{'--|','(','--(|)',{ft='lua',ts=true,{c={extensions={tsnode={p=50,inside={'comment'}}}}}}},
        --{'|','(','(|',{ft='lua',ts=true,{c={extensions={tsnode={p=50,inside={'comment'}}}}}}},
    },
    ext_fly={
        {'[{( | )}]',']','[{(  )}]|'},
        {'(|a)',')','()|a)'},
        {'("|")',')','("")|',{c={{'"','"',p=11,fly=true},extensions={fly={nofilter=true}}}}},
        {'"(|)"','"','"()"|',{c={{'"','"',p=11,fly=true},extensions={fly={nofilter=true}}}}},
        {[['"' "(|)"]],'"',[['"' "()"|]],{c={{'"','"',p=11,fly=true}}}},
        {'({|})',')','({)|})',{interactive=true,c={extensions={fly={undomap='<C-u>'}}}}},
        {'|(  )',')','(  )|'},
        {'|(  )',')',')|(  )',{c={extensions={fly={only_jump_end_pair=true}}}}},
        {'<<(|)>>','>','<<()>>|',{c={{'<<','>>',fly=true}}}},
        {'(<<|>>)',')','(<<>>)|',{c={{'<<','>>',fly=true}}}},
    },
    ext_tsnode={
        {'|--)','(','(|)--)',{ts=true}},
        {'/*(*/|)',')','/*(*/)|)',{ts=true,ft='c'}},
        {'|\n```lua\n)\n```','(','(|)\n```lua\n)\n```',{ts=true,ft='markdown',skip=true}},
        {'```lua\na|\n```\n)','(','\n```lua\na(|)\n```\n)',{ts=true,ft='markdown',skip=true}},
        {'```python\nf|\n```',"'","\n```python\nf'|'\n```",{ts=true,ft='markdown',skip=true}},
        --TODO: write more tests (like multiline empty line...)
    },
    utf8={
        {"'á|',","'","'á'|,",{interactive=true}}, --simple
        {'(|)aøe,','','(|aøe),',{interactive=true}}, --faswarp
        {'(|aáa),','','|aáa,',{interactive=true}}, --backspace
        {'|"¿qué?",','(','(|"¿qué?"),',{interactive=true}}, --ext.suround
        {"ä|,","'","ä'|,",{interactive=true}}, --ext.alpha
        {'"ě""|",','','"ě"|,',{ts=true,interactive=true}}, --backspace
        {"'ø',|","'","'ø','|'",{ts=true,interactive=true}}, --treesitter
        {"{'ø',{}|}",'{',"{'ø',{}{|}}",{ts=true,interactive=true}} --TODO: fix
    },
    string={
        {'| ")"','(','(|) ")"',{ts=true}},
        {'"|")','(','"(|)")',{ts=true}},
        {[[|"'"]],"'",[['|'"'"]],{ts=true}},
        {[['""(|)']],')',[['""()|']],{ts=true}},
        {'("|")',')','(")|")',{ts=true}},
        {[[| '\')']],'(',[[(|) '\')']],{ts=true}},
        {'| [[)]]','(','(|) [[)]]',{ft='lua',ts=true}},
        {'|\n")"','(','(|)\n")"',{ts=true}},
        {'"|"\n)','(','"(|)"\n)',{ts=true}},
        {"'''|'","'","''''|",{ts=true,ft='lua'}},
        {[["'"|"'"]],'"',[["'""|""'"]],{ts=true}},
        {[['"' '"' |]],"'",[['"' '"' '|']],{ts=true}},
        {"f'|","'","f''|",{ts=true,ft='lua'}},
        --TODO: test multiline string (python)
    },
    options={
        ---pair
        {'|','(','(|',{c={map=false}}},
        {'|','(','(|',{c={pair_map=false}}},
        {'|','I="("\r','(',{interactive=true,c={cmap=true}}},
        {'|','I="("\r','(',{interactive=true,c={pair_cmap=true}}},
        ---bs
        {'(|)','','|)',{c={bs={enable=false}}}},
        {'(|)','','|)',{c={bs={map=false}}}},
        {'(|)','a','|',{c={bs={map='a'}}}},
        {'(|)','b','|',{c={bs={map={'a','b'}}}}},
        {'|','I="("\r',')',{interactive=true,c={bs={cmap=false}}}},
        {'(|foo)','','|foo)',{c={bs={overjumps=false}}}},
        {'( | )','','(| )',{c={bs={space=false}}}},
        ---cr
        {'(|)','\r','(\n|)',{c={cr={enable=false}}}},
        {'(|','\r','(\n|\n)',{c={cr={autoclose=true}}}},
        ---space
        {'(|)',' ','( |)',{c={space={enable=false}}}},
        {'(|)',' ','( |)',{c={space={map=false}}}},
        {'|','I="( \r','( )',{interactive=true,c={space={cmap=false}}}},
        {'+ [|]',' ','+ [ |]',{ft='lua',c={space={check_box_ft={'lua'}}}}},
        --TODO: write more tests
    },
    filter={
        {'\\(|)','','\\|)'},
        {'\\"|"','','\\|"'},
        {'(|\\)','','|\\)'},
        {'\\()|','','\\(|',{skip=true}},
        {'\\(\n|\n)','','\\(|\n)',{skip=true}},
        {'\\(|)','\r','\\(\n|)'},
        {'(|\\)','\r','(\n|\\)'},
        {'\\(|','','\\(|'},
        {'\\"|','','\\"|'},
        {'{(|)\\}}','','{(|\\})}'},
        {'(|\\)),','','(|\\),)'},
        {'{(|\\{)}','','{(|)\\{}'},
        {'\\(|)',' ','\\( |)'},
        {'\\( |)','f','\\( f)',{interactive=true,c={space2={enable=true}}}},
        {'|"\\"','(','(|)"\\"'},
        {'("|")',')','(")|")',{ts=true,c={{'"','"',fly=true,p=11},extensions={fly={nofilter=false}}}}},
    },
    multiline={
        {'|\n)','(','(|\n)'},
        {'(\n|)',')','(\n)|'},
        {'\n|)',')','\n)|)'},
        {'(|\n)','(','((|)\n)'},
        {'(\n|\n)','(','(\n(|)\n)'},
        {'()\n|)',')','()\n)|)'},
        {'(\n(|)',')','(\n()|)'},
        {'(|\n))','(','((|\n))'},
        {'"""\n|"""','"','"""\n"""|',{ft='python'}},
        {'"\n|"','"','"\n"|"'},
        {'|\n>','<','<|>\n>',{c={{'<','>',multiline=false}}}},
        {'<\n|>','>','<\n>|>',{c={{'<','>',multiline=false}}}},
        {'(|)\n',')','()|\n'},
        {'\n(|)\n',')','\n()|\n'},
        {'\n |\n()','(','\n (|)\n()'},
        {'\n "|"\n""','"','\n ""|\n""',{c={config_internal_pairs={{'"','"',multiline=true}}}}},
        {'(\n  (|)\n)','','(\n  |\n)'},
        {'\n"|"','"','\n""|'},
        {"\n'|'","'","\n''|",{ts=true,ft='lua'}},
        {'(\n\n|\n)','(','(\n\n(|)\n)'},
    },
    DEV_run_multiline={
        {'\n|','a','\na|'},
        {'\n|\n','','|\n'},
        {'foo\n|bar\n','','foo|bar\n'},
        {'\n|\n','','\n|'},
        {'a\nb|c\nd','\r','a\nb\n|c\nd'},
        {'f|','\r','foo\n|',{abbr={f='foo'}}},
    },
}
