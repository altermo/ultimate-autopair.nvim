local dont_rec_check={}
---@type table<string,ua.test[]>
local list_of_tests={
    simple={
        {'|','(','(|)'},
        {'|)','(','(|)'},
        {'(|)','(','((|))'},
        {'(|','(','((|)'},
        {'|)(','(','(|)('},
        {'() |','(','() (|)'},
        {'(|))','(','((|))'},

        {'(|)',')','()|'},
        {'((|))',')','(()|)'},
        {'|)',')',')|)'},
        {'(|))',')','()|)'},
        {'()|)',')','())|)'},
        {'( |)',')','( )|'},
        {'(|)(()',')','()|(()'},

        {'|','"','"|"'},
        {'"|"','"','""|'},
        {'|"','"','"|"'},
        {'"|','"','""|'},
        {"'' |","'","'' '|'"},
        {'"a|b"','"','"a"|"b"'},

        {'|','f(','foo(|)',cmd='abbr <buffer>f foo'},

        --{'((|))','<lt>','((<|>))',{{'((<','>))'}}},
        {'|','*','*|*',{{'*','*'},{'**','**'}}},
        --{'*|*','*','**|**',{{'*','*'},{'**','**'}}},
        --{'*|*','*','**|**',{{'**','**'}}},
        --{'**|**','*','***|***',{{'**','**'},{'***','***'}}},
        --{'**|**','*','***|***',{{'***','***'}}},
        --{'**|**','*','****|',{{'*','*'},{'**','**'}}},
        --{'*|**','*','**|**',{{'*','*'},{'**','**'}}},
        --{'**|*','*','***|*',{{'*','*'},{'**','**'}}},
        --{'****|','*','*****|*',{{'*','*'},{'**','**'}}},
        --{'***|*','*','****|*',{{'**','**'}}},
        --{'|','{','{|},',{c={{'{','},'}}}},
        {'""|""','"','"""|"""'},
        {'"|""','"','""|""'},
        {'""|"','"','"""|"'},

        {'|','<esc>a(<esc>..a','(((|)))'},
        {'|','<esc>3a(<esc>a','(((|)))'},
        {'|foo','<esc>R(','(|)o'},

        {'<!-|','-','<!--|'},
        --{'<!-|','-','<!--|-->',{ft='markdown'}},
        --{'<!-|-->','-','<!--|-->',{ft='markdown'}},
        --{'<!--|-->','-','<!---->|',{ft='markdown'}},
        --{'""|','"','"""|"""',{ft='python'}},
        --{'"""|"""','"','""""""|',{ft='python'}},

        {'<cr|','>','<cr>|<cr>',{{'<cr>','<cr>'}}},
        {'\0|\0',"'","\0'|'\0"},

        --{'(|)',')','()|)',{change={{'(',{'',')'}}}}},
        --{'|','(','(|)',{change={{{'(','('},{'',')'}}}}},
        --{'|','(','(|',{change={{{'','('},')'}}}},
        --{'(|)',')','()|',{change={{{'','('},')'}}}},
        --{'|','"','"|',{change={{{'','"'},'"'}}}},
        --{'"|"','"','""|""',{change={{'"',{'','"'}}}}},

        {'&&|??','?','&&??|',{{'&','?'},{'&&','??'}}},
        {'&&|??','?','&&??|',{{'&&','??'},{'&','?'}}},
    },
    modes={
        {'|','<C-r>="(\r','()|'},
        {'|','&','&|',{{'&','?',mode='c'}}},
        {'|','<cmd>lua vim.api.nvim_open_term(0,{on_input=function (_,chan,_,i) vim.api.nvim_chan_send(chan,i) end}) vim.uv.run()\r(','(|)',{map_mode='t'},trim=true},
    },
    multiline={
        {'|\n)','(','(|\n)'},
        {'(|\n)','(','((|)\n)'},
        {'(\n|\n)','(','(\n(|)\n)'},
        {'(|\n))','(','((|\n))'},
        {'\n |\n()','(','\n (|)\n()'},
        {'(\n\n|\n)','(','(\n\n(|)\n)'},
        {'|\n>','<lt>','<|>\n>',{{'<','>',multiline=false}}},

        {'\n|)',')','\n)|)'},
        {'(\n|)',')','(\n)|'},
        {'()\n|)',')','()\n)|)'},
        {'(\n(|)',')','(\n()|)'},
        {'(|)\n',')','()|\n'},
        {'\n(|)\n',')','\n()|\n'},
        {'<\n|>','>','<\n>|>',{{'<','>',multiline=false}}},
        {'<|>\n','>','<>|\n',{{'<','>',multiline=false}}},
        {'<\n|>','>','<\n>|>',{{'<','>',multiline=false}}},
        {'<|>\n','>','<>|\n',{{'<','>',multiline=false}}},

        {'"\n|','"','"\n"|"'},
        {'"\n|"','"','"\n"|"'},
        {'\n"|"','"','\n""|'},
        {"\n'|'","'","\n''|",ft='lua'},
        --{'"""\n|"""','"','"""\n"""|',ft='python'},
        {'*\n|*','*','*\n*|',{{'*','*',multiline=true}}},
        {'*\n|*','*','*\n*|*',{{'*','*',multiline=false}}},
        {'\n "|"\n""','"','\n ""|\n""',{default={pair={['""']={multiline=true}}}},ft='lua'},
        {'\n "\n|"\n""','"','\n "\n"|\n""',{default={pair={['""']={multiline=true}}}},ft='lua'},
        {'"\n|','"','"\n"|',{default={pair={['""']={multiline=true}}}}},

        {'(\n  (|)\n)','<bs>','(\n  |\n)'},
        {'|','f\r','foo\n|',cmd='abbr <buffer>f foo'},
        {'|','f ','foo |',cmd='abbr <buffer>f foo'},
    },
    utf8={
        {'|','‹','‹|›',{{'‹','›'}}},
        {'‹|›','›','‹›|',{{'‹','›'}}},
        {'a|b','‹','a‹|b',{{'‹‹','››'}}},
        {'a‹|b','‹','a‹‹|››b',{{'‹‹','››'}}},
        -- {'a‹‹|››b','‹','a‹‹‹|›››b',{{'‹‹','››'},{'‹‹‹','›››'}}},
        {'a‹‹b›|›c','›','a‹‹b››|›c',{{'‹‹','››'}}},
        {'a‹‹b|››c','›','a‹‹b››|c',{{'‹‹','››'}}},
        {'a‹|b››c','‹','a‹‹|b››c',{{'‹‹','››'}}},
        {'|','˚','˚|˚',{{'˚','˚'}}},
        {'a˚b|˚c','˚','a˚b˚|c',{{'˚','˚'}}},
        {'a|˚b','˚','a˚|˚b',{{'˚','˚'}}},
        {'a˚b|c','˚','a˚b˚|c',{{'˚','˚'}}},
        {'a˚b˚c|d','˚','a˚b˚c˚|˚d',{{"˚","˚"}}},
        {'a˚b|c˚d','˚','a˚b˚|˚c˚d',{{'˚','˚'}}},
        {'a|b','˚','a˚|b',{{'˚˚','˚˚'}}},
        {'a˚|b','˚','a˚˚|˚˚b',{{'˚˚','˚˚'}}},
        {'a˚˚b|˚˚c','˚','a˚˚b˚˚|c',{{'˚˚','˚˚'}}},
        {'a˚|b˚˚c','˚','a˚˚|b˚˚c',{{'˚˚','˚˚'}}},
        -- {'a˚˚b˚|˚c','˚','a˚˚b˚˚|˚c',{c={{'˚˚','˚˚'}}}},
        {'fn("π",|)','"','fn("π","|")',ft='lua'},
        {"'ā|',","'","'ā'|,"},
        -- {',(|aŐe),foo,','<A-e>',',(|aŐe,foo),'}, --fastwarp
        -- {',‹‹|aŐe››,foo,','<A-e>',',‹‹|aŐe,foo››,',{c={{'‹‹','››'}},skip=true}}, --fastwarp
        -- {',˚˚|aŐe˚˚,foo,,','<A-e>',',˚˚|aŐe,foo˚˚,',{c={{'˚˚','˚˚'}},skip=true}}, --fastwarp
        -- {',(|)aŐe,','<A-e>',',(|aŐe),',{skip='Non-ascii characters are never treated as word characters in fastwarp.'}}, --fastwarp
        -- {',‹‹|››aŐe,','<A-e>',',‹‹|aŐe››,',{c={{'‹‹','››'}},skip='Non-ascii characters are never treated as word characters in fastwarp.'}}, --fastwarp
        -- {',˚˚|˚˚aŐe,','<A-e>',',˚˚|aŐe˚˚,',{c={{'˚˚','˚˚'}},skip='Non-ascii characters are never treated as word characters in fastwarp.'}}, --fastwarp
        -- --{'(|aáa),','','|aáa,',{interactive=true}}, --backspace
        -- --{'|"¿qué?",','(','(|"¿qué?"),',{interactive=true}}, --ext.surround
        {"ā|,","'","ā'|,"}, --filter.alpha
        -- {'"ě""|",','<bs>','"ě"|,',{ft='lua'}}, --backspace
        -- {"'Ő',|","'","'Ő','|'",{ft='lua'}}, --treesitter
        {"{'Ő',{}|}",'{',"{'Ő',{}{|}}",ft='lua'}
    },

    filter_alpha={
        {'don|t',"'","don'|t"},
        {'ǎ|',"'","ǎ'|"},
        {'ä|',"'","ä'|"},
        {'ä|',"'","ä'|'",cmd='set iskeyword='},
        {'_|',"'","_'|"},
        {'-|',"'","-'|'"},
        {'-|',"'","-'|",ft='lisp'},
        {'```query\n.|\n```',"'","```query\n.'|\n```",ft='markdown'},
        {"'a|'","'","'a'|"},
        {'f|',"'","f'|"},
        {'f|',"'","f'|'",ft='python'},
        {'Rb|',"'","Rb'|'",ft='python'},
        {'bar|',"'","bar'|",ft='python'},
        -- {"a' |","'","a' '|'",{c={filter={alpha={filter=true}}}}},
        -- {"a' |","'","a' '|",{c={filter={alpha={filter=false}}}}},
        {'|a','<lt>','<|a',{{'<','>',filter={alpha={after=true}}}}},
        {'a|','<lt>','a<|',{{'<','>',filter={alpha={before=true}}}}},
        {'<|','<lt>','<<|>>',{{'<<','>>',filter={alpha={after=true}}}}},
        {'<|a','<lt>','<<|a',{{'<<','>>',filter={alpha={after=true}}}}},
        {'a<|','<lt>','a<<|',{{'<<','>>',filter={alpha={before=true}}}}},
        {'<<|>>a','>','<<>|>>a',{{'<<','>>',filter={alpha={after=true}}}}},
        {'<< |>>','>','<< >>|',{{'<<','>>',filter={alpha={before=true}}}}},
        {'<<a|>>','>','<<a>|>>',{{'<<','>>',filter={alpha={before=true}}}}},
        -- {'b""|','"','b"""|"',{ft='python',c={change={{'"""','"""',alpha={before=true}}}}}},
        -- {'foo|',"'","foo'|"},
        -- {'foo|',"'","foo'|'",ft='lua'},
        -- {'foo"don|"',"'",[[foo"don'|"]],ft='lua'},
        -- {'--don|',"'","--don'|",ft='lua'},
        -- {'foo"don|"',"'",[[foo"don'|"]],{treesitter=false},ft='lua'},
        -- {'--don|',"'","--don'|",{treesitter=false},ft='lua'},
        {"f'|","'","f''|"},
    },
    filter_escape={
        {'\\|','(','\\(|'},
        {'\\\\|','(','\\\\(|)'},
        {'|\\)','(','(|)\\)'},
        {'\\(|)',')','\\()|)'},
        {'\\( |)',')','\\( )|)'},
        -- {'\\<!-|','-','\\<!--|',{ft='markdown'}},
        -- {'<!-| \\-->','-','<!--|--> \\-->',{ft='markdown'}},
        -- {'<!--\\-->|-->','-','<!--\\-->-->|',{ft='markdown'}},
        {'\\|','(','\\(|\\)',{{'\\(','\\)'}}},
        {'\\\\|','(','\\\\(|)',{{'\\(','\\)'}}},
        {'\\(|\\)','\\','\\(\\)|',{{'\\(','\\)'}}},
        {'\\(|)','<bs>','\\|)'},
    },
    filter_cmdtype={
        {'|','<C-r>="(<end>"\r','()|',{root_filter={cmdtype={skip={}}}}},
        {'|','<C-r>="(<end>"\r','(|',{root_filter={cmdtype={skip={'='}}}}},
        {'|','<C-r>=input("")\r(\r','(|'},
        {'|','<C-r>=input("")\r(\r','()|',{default={pair={['()']={filter={inherit_root_filters=false}}}}}},
    },
    filter_filetype={
        {'|','<lt>','<|',ft='lua',{{'<','>',filter={filetype={nft={'lua'}}}}}},
        {'```lua\n|\n```','<lt>',"```lua\n<|>\n```",ft='markdown',{{'<','>',filter={filetype={ft='lua'}}}}},
        {'```lua\n|\n```','<lt>',"```lua\n<|\n```",ft='markdown',{{'<','>',filter={filetype={treesitter=false,ft='lua'}}}}},
        {'```lua\n|\n```','<lt>',"```lua\n<|\n```",ft='markdown',{{'<','>',filter={filetype={nft='lua'}}}}},
        {'```lua\n|\n```','<lt>',"```lua\n<|>\n```",ft='markdown',{{'<','>',filter={filetype={treesitter=false,nft='lua'}}}}},
        {'|','(','(|',ft='TelescopePrompt'},
        {'|\nlua )\nlua )\nlua )','(','(|)\nlua )\nlua )\nlua )',ft='vim'},
        {'lua a|b\n)','(','lua a(|)b\n)',ft='vim'},
        -- {'<!-|','-','<!--|'},
        -- {'<!-|','-','<!--|-->',ft='markdown'},
        -- {'""|','"','"""|"'},
        -- {'""|','"','""""|"""',ft='python'},
    },
    filter_tsnode={
        {'"|"','<lt>','"<|"',{{'<','>',filter={tsnode={nodeclass_filter={[true]='exclude'}}}}},ft='lua'},
        {'""|','<lt>','""<|>',{{'<','>',filter={tsnode={nodeclass_filter={[true]='exclude'}}}}},ft='lua'},
        {'|""','<lt>','<|>""',{{'<','>',filter={tsnode={nodeclass_filter={[true]='exclude'}}}}},ft='lua'},
        {'--|','<lt>','--<|',{{'<','>',filter={tsnode={nodeclass_filter={[true]='exclude'}}}}},ft='lua'},
        {'|--','<lt>','<|>--',{{'<','>',filter={tsnode={nodeclass_filter={[true]='exclude'}}}}},ft='lua'},
        {'| ")"','(','(|) ")"',ft='lua'},
        {'"|")','(','"(|)")',ft='lua'},
        {[[|"'"]],"'",[['|'"'"]],ft='lua'},
        {[['""(|)']],')',[['""()|']],ft='lua'},
        {'("|")',')','(")|")',ft='lua'},
        {[[| '\')']],'(',[[(|) '\')']],ft='lua'},
        {'| [[)]]','(','(|) [[)]]',ft='lua'},
        {'|\n")"','(','(|)\n")"',ft='lua'},
        {'"|"\n)','(','"(|)"\n)',ft='lua'},
        {"'''|'","'","''''|",ft='lua'},
        {'| ")"','(','(| ")"',{treesitter=false},ft='lua'},
        {'| ")"','(','(| ")"',{treesitter=true,default={pair={['()']={treesitter=false}}}},ft='lua'},
        -- {'local a=| }','{','local a={|} }',{ft='lua',c={filter={tsnode={separate={'table_constructor'},detect_after="{"}}},skip=true}}, --TODO: make detect_after only run on insert
        -- {"let a: Vec<|a>;","'","let a: Vec<'|a>;",{ft='rust',c={filter={tsnode={dont={'lifetime'},detect_after="'"}}},skip=true}}, --TODO: only do on insertion, not on general filtering
        -- {"let a: Vec<a>;|","'","let a: Vec<'a>;'|'",{ft='rust',c={filter={tsnode={dont={'lifetime'},detect_after="'"}}},skip=true}},
        -- {"|","'","'|'",{ft='rust',c={filter={tsnode={dont={'lifetime'},detect_after="'"}}},skip=true}},
        {[["'"|"'"]],'"',[["'""|""'"]],ft='lua'},
        {[['"' '"' |]],"'",[['"' '"' '|']],ft='lua'},
        -- {'| ")"','(','(|) ")"',{ft='lua',c={filter={tsnode={merge=false,separate={lua={'string'}}}}}}},
        -- {'| ")"','(','(| ")"',{ft='lua',c={filter={tsnode={merge=false,separate={markdown={'string'}}}}}}},
        {"f'|","'","f''|",ft='lua'},
        ----TODO: test multiline string (python)
        ----TODO: test more injected filter
    },
    filter_lib={
        --TODO: move some of these to the correct location, remove some of them, and something something

        -- -- inlisp
        -- {'|',"'","'|",{ft='lisp'}},
        -- {'|',"'","'|",{ft='lua',cmd='set lisp'}},
        -- {'"|"',"'",[["'|'"]],{ft='lua',cmd='set lisp'}},
        -- {'-- |',"'","-- '|'",{ft='lua',cmd='set lisp'}},
        -- {'#|',"'","#'|'",{cmd='set lisp commentstring=#\\ %s'}},
        -- {'|#',"'","'|#",{cmd='set lisp commentstring=#\\ %s'}},
        -- {'/*|*/',"'","/*'|'*/",{cmd='set lisp commentstring=/*%s*/'}},
        -- {'|/**/',"'","'|/**/",{cmd='set lisp commentstring=/*%s*/'}},
        -- {'/**/|',"'","/**/'|",{cmd='set lisp commentstring=/*%s*/'}},
        -- {'/**/|*/',"'","/**/'|*/",{cmd='set lisp commentstring=/*%s*/'}},
        -- {'/*|',"'","/*'|'",{cmd='set lisp commentstring=/*%s*/'}},

        --TODO: test that generic function filters work
        --{'"|"',"'",[["'|'"]],{ts=true,ft='fennel',tsft='lua'}},
        --{'|','(','(|',{c={extensions={cond={cond=function () return false end}}}}},
        --{'#|','(','#(|',{c={extensions={cond={cond=function (_,o) return o.lines[o.row]:sub(o.col-1,o.col-1)~='#' end}}}}},
        --{'|#)','(','(|)#)',{c={extensions={cond={cond=function (_,o)
        --    return o.lines[o.row]:sub(o.col-1,o.col-1)~='#' end,filter=true}}}}},
        --{'"|"','(','"(|"',{ts=true,c={extensions={cond={cond=function(fns) return not fns.in_string() end}}}}},
        --{'--|a','(','--(|a',{ft='lua',ts=true,c={extensions={cond={cond=function (fns) return not fns.in_node('comment') end}}}}},
        --{'|','(','(|)',{ft='lua',ts=true,c={extensions={cond={cond=function (fns) return not fns.in_node('comment') end}}}}},
        --{'--|a','(','--(|)a',{ft='lua',ts=true,c={extensions={cond={cond=function (fns) return fns.in_node('comment') end}}}}},
        --{'|','(','(|',{ft='lua',ts=true,c={extensions={cond={cond=function (fns) return fns.in_node('comment') end}}}}},
        --{'""|a','(','""(|)a',{ft='lua',ts=true,c={extensions={cond={cond=function (fns) return fns.in_node('string') end}}},skip=true}},
    },

    map_backspace={
        {'(|)','<bs>','|'},
        {'[[|]]','<bs>','[|]'},
        {'[[|]','<bs>','[|]'},
        {'[|]]','<bs>','|]'},
        {'[]|]','<bs>','[|]'},
        {'][|][','<bs>',']|['},
        {'a[|]b','<bs>','a|b'},
        {'a"|"b','<bs>','a|b'},
        {'" "|" "','<bs>','" | "'},
        {'"|""','<bs>','|""'},
        {'" "|"','<bs>','" |"'},
        {'""| "','<bs>','"| "'},
        -- {"a'|'",'<bs>',"a|'"},
        -- {"a'|' '",'<bs>',"a|' '"},
        -- {'<|a>>','<bs>','|a>',{{'<','>',filter={alpha={before=true}}}}},
        {'[|foo]','<bs>','|foo'},
        {'"|foo"','<bs>','|foo"'},
        {'"|foo"','<bs>','|foo',{default={pair={['""']={backspace={overjump=true}}}}}},
        {'[|\n]','<bs>','|\n'},
        {'|','<C-r>="(a<left><bs>\r','a|'},
        -- {'<!--|-->','<bs>','<!-|-->'},
        -- {'a<!--|-->b','<bs>','a|b',{ft='markdown'}},
        -- {'a<!--|b-->c','<bs>','a|bc',{ft='markdown'}},
        -- {'a<!---->|b','<bs>','a|b',{ft='markdown'}},
    },

    default={
        {'|','(','(|',{default=false}},
        --TODO: write more tests for default
    },

    --TODO: test enable=false (for both maps and filters) (for both root and pairwise)
    --TODO: test multiline=false
    --TODO: test inherit (for both level 1 and 2)

    --- This should always be the last category
    config_validation={
        {'','','',{
            --TODO: ... I don't know what to do with this test... it is useful...
            default={
                'backspace',
                pair={
                    ['()']={multiline=false},
                }
            }
        },validate_and='no error'},
        {'','','',{
            --TODO: redo this whole test, once `ua.config` is finalized (to make sure all is covered)
            fallback={
                [true]=true,
                ['<A-e>']={i='',[true]=function () return 'a' end},
            },
            lazy=false,
            default=false,
            validate=4,
            err_format='default',
            map_mode='i',
            pair_map_mode={'i'},
            priority=1,
            multiline=true,
            use_filetype_getopt={[true]=true,lua=function (...) end},
            smart_pairing=true,
            treesitter_async=true,
            treesitter=true,
            perf={
                smart_pairing=dont_rec_check,
                treesitter=dont_rec_check,
                multiline=dont_rec_check,
                byte_limit=math.huge,
                row_limit=math.huge,
                timeout=math.huge,
            },
            root_filter={
                enable=true,
                filetype_multi={},
                filetype={enable=true,
                    ft='lua',
                    nft={'lua'},
                    treesitter=true,
                    temp_insert=false,
                    injectlang_separate=true,
                    filter_or=dont_rec_check,
                    filter=dont_rec_check,
                    singlechar=false,
                },
                tsnode_multi={},
                tsnode={enable=true,
                    separate_inclusive={lua='string'},
                    separate={'comment'},
                    exclude_inclusive={},
                    exclude={},
                    query={lua='(string) @separate'},
                    nodeclass_filter={},
                    filter_or=dont_rec_check,
                    filter=dont_rec_check,
                    singlechar=false,
                },
                cmdtype_multi={},
                cmdtype={enable=true,
                    skip={''},
                    filter_or=dont_rec_check,
                    filter=dont_rec_check,
                    singlechar=false,
                },
                escape_multi={},
                escape={enable=true,
                    filter_or=dont_rec_check,
                    filter=dont_rec_check,
                    singlechar=false,
                },
                alpha_multi={},
                alpha={enable=true,
                    before=true,
                    after=false,
                    fstring_smart=true,
                    insert_only=true,
                    filter_or=dont_rec_check,
                    filter=dont_rec_check,
                    singlechar=false,
                },
                {
                    on_iter=function (_) end,
                    pos=function (_) end,
                    once=function (_) return false end,
                    row=function (_) end,
                    enable=true,
                    on_iter_pos=function (_) end,
                    filter=dont_rec_check,
                    filter_or=dont_rec_check,
                    singlechar=false,
                },
            },
            {
                smart_pairing=true,
                mode='i',
                priority=1,
                multiline=true,
                filter=dont_rec_check,
                treesitter=true,
                '(',
                {{{')',mode='i',priority=1}},
                    function (_,_) return 'a' end,mode='i',priority=1,
                    filter=dont_rec_check,multiline=true,smart_pairing=true,
                    backspace={
                        treesitter=false,
                        enable=true,
                        space=true,
                        newline=true,
                        single_delete=true,
                        overjump='nonambiguous',
                        filter=dont_rec_check,
                    },
                    backspace_multi=dont_rec_check,
                    newline=dont_rec_check,
                    newline_multi=dont_rec_check,
                    space=dont_rec_check,
                    space_multi=dont_rec_check,
                    treesitter=true,
                },
                backspace=dont_rec_check,
                backspace_multi=dont_rec_check,
                newline=dont_rec_check,
                newline_multi=dont_rec_check,
                space=dont_rec_check,
                space_multi=dont_rec_check,
                --fastwarp=dont_rec_check,
                --fastwarp_multi=dont_rec_check,
            },
            backspace_multi={
                foo={
                    mode='i',
                    priority=1,
                    map={{'\t',priority=1,mode={'i','c'}},'<bs>'},
                    single_delete=true,
                    enable=true,
                    space=true,
                    overjump='nonambiguous',
                    newline=true,
                    filter=dont_rec_check,
                    treesitter=true,
                }
            },
            backspace={
                mode='i',
                priority=1,
                map='<bs>',
                single_delete=true,
                enable=true,
                space=true,
                overjump='nonambiguous',
                newline=true,
                treesitter=true,
                filter={
                    enable=true,
                    filetype_multi={},
                    filetype=dont_rec_check,
                    tsnode_multi={},
                    tsnode=dont_rec_check,
                    cmdtype_multi={},
                    cmdtype=setmetatable({skip=''},dont_rec_check),
                    escape_multi={},
                    escape=dont_rec_check,
                    alpha_multi={},
                    alpha=dont_rec_check,
                    inherit_root_filters={'filetype'},
                },
            },
            newline_multi={},
            newline={mode='i',priority=1,map='\r',enable=true,filter=dont_rec_check,treesitter=true,},
            space_multi={},
            space={mode='i',priority=1,map=' ',enable=true,filter=dont_rec_check,
                check_box_ft='lua',treesitter=true},
        },validate_and='no error, no bad idx'},
        {'','','',{default=true},validate_and='no error'},

        -- err: dont_set
        {'','','',{validate=2,default=false,
            a=1,
        },validate_and='expect error',expected_err=[[
            The option `a` is set, but it should not be set.]]},
        {'','','',{validate=2,default=false,
            map_mo=1,
        },validate_and='expect error',expected_err=[[
            The option `map_mo` is set, but it should not be set.

            Did you mean `map_mode`?]]},

        ---@diagnostic disable: assign-type-mismatch, redundant-parameter, missing-fields
        -- err: vtype
        {'','','',{validate=1,default=false,
            multiline=1,
        },validate_and='expect error',expected_err=[[
            The option `multiline` (with the value `1`) should be the type `boolean`, but got a `number`.]]},
        {'','','',{validate=1,default=false,
            map_mode=1,
        },validate_and='expect error',expected_err=[[
            The option `map_mode` should be either
            * the type `table`
            * the type `string`
            But got the value `1` with the type `number`.]]},
        {'','','',{validate=1,default=false,
            use_filetype_getopt={[1]=true},
        },validate_and='expect error',expected_err=[[
            The option `use_filetype_getopt#index[1]` should be either
            * the value `true`
            * the type `string`
            But got the value `1` with the type `number`.]]},

        -- err: enum
        {'','','',{validate=1,default=false,
            map_mode='a',
        },validate_and='expect error',expected_err=[[
            The option `map_mode` contains the value `"a"`.
            However, that option should be one of `{ "i", "c", "t", "v", "o", "s", "n" }`.]]},

        -- err: not_list
        {'','','',{validate=2,default=false,
            map_mode={a=1},
        },validate_and='expect error',expected_err=[[
            The option `map_mode` should be a list (see `:help vim.islist()`).]]},

        -- err: func_n_params
        {'','','',{validate=3,default=false,
            use_filetype_getopt=function (_,_,_) end,
        },validate_and='expect error',expected_err=[[
            The option `use_filetype_getopt` is a function which should take two and only two arguments.
            It currently takes 3 arguments.]]},
        {'','','',{validate=3,default=false,
            use_filetype_getopt=function (_,_,_,...) end,
        },validate_and='expect error',expected_err=[[
            The option `use_filetype_getopt` is a function which should take two and only two arguments.
            It currently takes 3 or more arguments.]]},
        {'','','',{validate=3,default=false,
            use_filetype_getopt=function (_) end,
        },validate_and='expect error',expected_err=[[
            The option `use_filetype_getopt` is a function which should take two and only two arguments.
            It currently takes 1 argument.]]},

        -- err: not_detected filetype
        {'','','',{validate=3,default=false,
            space={check_box_ft='NOT_A_FILETYPE'},
        },validate_and='expect error',expected_err=[[
            The option `space.check_box_ft` (with the value `"NOT_A_FILETYPE"`) is not detected as a filetype.]]},

        -- err: not_detected query_filetype
        {'','','',{validate=1,default=false,
            root_filter={tsnode={query={lua='NOT_A_NODE'}}}
        },validate_and='expect error',expected_err=[[
            The option `root_filter.tsnode.query.lua` (with the value `"NOT_A_NODE"`) is not detected as a valid query for filetype lua.]]},

        -- err: not_detected TSNode
        {'','','',{validate=1,default=false,
            root_filter={tsnode={separate='a b'}}
        },validate_and='expect error',expected_err=[[
            The option `root_filter.tsnode.separate` (with the value `"a b"`) is not detected as a valid TSNode type.]]},

        -- err: not_detected TSNode filetype
        {'','','',{validate=1,default=false,
            root_filter={tsnode={separate={lua='NOT_A_NODE'}}}
        },validate_and='expect error',expected_err=[[
            The option `root_filter.tsnode.separate.lua` (with the value `"NOT_A_NODE"`) is not detected as a valid TSNode type for filetype lua.]]},

        -- err: not_detected TSLang
        {'','','',{validate=3,default=false,
            root_filter={tsnode={separate={NOT_A_TSLANG=''}}}
        },validate_and='expect error',expected_err=[[
            The option `root_filter.tsnode.separate#index["NOT_A_TSLANG"]` (with the value `"NOT_A_TSLANG"`) is not detected as a treesitter language.]]},

        -- err: need_set
        {'','','',{validate=1,default=false,
            newline={}
        },validate_and='expect error',expected_err=[[
            The option `newline` requires the option `newline.map` to be set.]]},
        {'','','',{validate=1,default=false,
            backspace={map={{'<bs>'}}},
        },validate_and='expect error',expected_err=[[
            The option `backspace.map[1]` requires one of the following options to be set:
            * `backspace.map[1].mode`
            * `backspace.mode`
            * `map_mode`]]},
        {'','','',{validate=1,default=false,
            {'(',')',backspace_multi={foo={}}},map_mode='i'
        },validate_and='expect error',expected_err=[[
            The option `[1].backspace_multi.foo` requires the option `backspace_multi.foo` to be set.
        ]]},
        ---@diagnostic enable: assign-type-mismatch, redundant-parameter, missing-fields

        ---TODO: test the different err_formats
        ---TODO: is there any error type we missed?
    }
}

---@class ua.test
---@field [1] string
---@field [2] string
---@field [3] string
---@field [4] ua.config?
---@field ft string?
---@field cmd string?
---@field trim boolean?
---@field I any
---@field validate_and?
---|'no error, no bad idx'
---|'no error'
---|'expect error'
---@field expected_err? string

---@class ua.test.instance
---@field handler ua.health.handler
---@field _chan number
local instance_meta={}
---@return any
function instance_meta:request(...)
    return vim.rpcrequest(self._chan,...)
end
---@param cmd string
---@return string
function instance_meta:exec(cmd)
    return self:request('nvim_exec2',cmd,{output=true}).output
end
---@param cmd string
---@return any
function instance_meta:exec_lua(cmd,...)
    return self:request('nvim_exec_lua',cmd,{...})
end
---@param cmd string
---@return boolean,any
function instance_meta:exec_lua_pcall(cmd,...)
    return pcall(self.exec_lua,self,cmd,...)
end
local function create_instance(handler)
    local chan=vim.fn.jobstart({vim.v.progpath,'--embed','--headless','--clean','-i','NONE','-u','NONE'},{rpc=true})
    vim.schedule(function ()
        pcall(vim.fn.jobstop, chan)
    end)
    ---@type ua.test.instance
    local instance={
        handler=handler,
        _chan=chan,
    }
    setmetatable(instance,{__index=instance_meta})
    return instance
end

---@param dev boolean?
local get_tests_by_config=function (handler,dev)
    local config_to_tests={}
    for category,tests in pairs(list_of_tests) do
        for index,test in pairs(tests) do
            local conf=test[4] or {}
            if test.I then
                if dev then
                    handler.error("`I` set for a test, most test are ignored")
                end
                return {[conf]={[category]={[index]=test}}}
            end
            for config,_ in pairs(config_to_tests) do
                if vim.deep_equal(conf,config) then
                    config_to_tests[config][category][index]=test
                    goto continue
                end
            end
            config_to_tests[conf]=vim.defaulttable(function () return {} end)
            config_to_tests[conf][category][index]=test
            ::continue::
        end
    end
    return config_to_tests
end


local function set_lines_and_pos(instance,lines)
    lines=vim.split(lines,'\n')
    local row,col
    for k,v in ipairs(lines) do
        col=v:find('|',1,true)
        if col then row=k break end
    end
    assert(row)
    lines[row]=lines[row]:sub(0,col-1)..lines[row]:sub(col+1)
    instance:request('nvim_buf_set_lines',0,0,-1,true,lines)
    instance:request('nvim_win_set_cursor',0,{row,col-1})
end
local function feed(instance,input)
    if instance:request('nvim_input',input)~=#input then return false end
    local errmsg=instance:request('nvim_get_vvar','errmsg')
    if errmsg~='' then instance:exec('let v:errmsg=""') end
    return errmsg
end
local function create_backtrace(test,actual)
    local ret=('{Initial}:\n%s\n{Input}: `%s`\n{Expected-result}:\n%s'):format(test[1],test[2],test[3])
    if actual then ret=ret..('\n{Actual-result}:\n%s'):format(actual) end
    if next(test,next(test,next(test,next(test)))) then
        test[1]=nil
        test[2]=nil
        test[3]=nil
        ret=('{Test-opts}:\n%s\n'):format(vim.inspect(test))..ret
    end
    return ret
end
local function get_lines_and_pos(instance,trim)
    local lines=instance:request('nvim_buf_get_lines',0,0,-1,true)
    local row,col=unpack(instance:request('nvim_win_get_cursor',0))
    lines[row]=lines[row]:sub(1,col)..('|')..lines[row]:sub(col+1)
    local line=table.concat(lines,'\n')
    if trim then
        line=vim.trim(line)
    end
    return line
end
---@param test ua.test
---@param instance ua.test.instance
---@return string?
local function validate_config(instance,test,category,index)
    if test.validate_and=='no error, no bad idx' or test.validate_and=='no error' then
        local no_bad_idx=test.validate_and=='no error, no bad idx'
        local noterr,errmsg=instance:exec_lua_pcall([[
        local category,index=...
        local ua_conf=require'ultimate-autopair.test'.tests[category][index][4]
        ]]..(no_bad_idx and [[
        local dont_rec_check=assert(require'ultimate-autopair.test'._dont_rec_check)

        local function recursive_make_err_on_out_of_bounds_idx(tbl,_idx)
            _idx=_idx==nil and '' or _idx
            if tbl==dont_rec_check or getmetatable(tbl)==dont_rec_check then
                return
            end
            assert(getmetatable(tbl)==nil or vim.tbl_isempty(getmetatable(tbl)))
            for idx,val in pairs(tbl) do
                if type(val)=='table' then
                    recursive_make_err_on_out_of_bounds_idx(val,_idx..'.'..idx)
                end
            end

            setmetatable(tbl,{__index=function (_,idx)
                error('index in test config not set: `'.._idx..'.'..idx..'`')
            end})
        end
        recursive_make_err_on_out_of_bounds_idx(ua_conf)
        ]] or '')..[[

        require'ultimate-autopair'.setup(ua_conf)
        ]],category,index)
        if noterr then return end
        test[1]=nil
        test[2]=nil
        test[3]=nil
        local msg=('test(%s) errord:\n{Error:}\n%s\n\n{Test-opts:}\n%s'):format(category,errmsg,vim.inspect(test))
        return msg
    elseif test.validate_and=='expect error' then
        local noterr,err=instance:exec_lua_pcall([[
        local category,index=...
        local ua_conf=require'ultimate-autopair.test'.tests[category][index][4]
        require'ultimate-autopair'.setup(ua_conf)
        ]],category,index)
        if noterr then
            err='NO ERROR'
        end
        err=err:gsub('^[^\n]+\n\n\n%-+\n','')
        err=err:gsub('\n%-+\n.*$','')
        if (test[4].validate or 0)>1 then
            err=err:gsub("Configuration for the plugin 'ultimate%-autopair' is POSSIBLY incorrect:\n\n",'')
        else
            err=err:gsub("Configuration for the plugin 'ultimate%-autopair' is incorrect:\n\n",'')
        end
        local expected_err=('\n'..test.expected_err):gsub('\n +','\n'):gsub('^%s+',''):gsub('%s+$','')
        if err==expected_err then return end
        local msg=('test(%s) did not error correctly:\n{Expected-error:}\n%s\n{Actual-error:}\n%s'):format(category,expected_err,err)
        return msg
    else
        error('unreachable')
    end
end
-- local function assert_no_autoconvert(s)
--     local char=s:match('[\194\195][\128-\191]')
--     if char then
--         error(('DEV ERROR: The `%s` in test string `%s` may autoconvert\nreplace with ascii or character with code >255'):format(char,s))
--     end
-- end
---@param instance ua.test.instance
---@param ctests table<string,ua.test[]>
---@return 'error'?
local function run_tests(instance,ctests)
    local loaded_config=false
    for category,tests in pairs(ctests) do
        for index,test in pairs(tests) do
            assert(type(test[1])=='string')
            assert(type(test[2])=='string')
            assert(type(test[3])=='string')
            assert(test[4]==nil or type(test[4])=='table')
            -- assert_no_autoconvert(test[1])
            -- assert_no_autoconvert(test[2])
            -- assert_no_autoconvert(test[3])

            if test.validate_and then
                local msg=validate_config(instance,test,category,index)
                if msg then
                    instance.handler.error(msg)
                end
                goto continue
            end

            assert(test[1]:find('|'))
            assert(not test[2]:find('|'))
            assert(test[3]:find('|'))

            if not loaded_config then
                instance:exec_lua([[
                local category,index=...
                local ua_conf=require'ultimate-autopair.test'.tests[category][index][4]
                require'ultimate-autopair'.setup(ua_conf)
                ]],category,index)
                loaded_config=true
            end
            instance:exec('stopinsert')
            instance:exec('bwipeout!')
            instance:exec_lua('vim.cmd.edit(...)',vim.fn.tempname())
            instance:exec('set all&')
            instance:exec('startinsert')
            if test.ft then
                instance:exec_lua('vim.cmd.setf(...)',test.ft)
            end
            if test.cmd then
                instance:exec(test.cmd)
            end
            set_lines_and_pos(instance,test[1])
            local errmsg=feed(instance,test[2])
            if errmsg==false then
                local msg=('test(%s) went wrong:\nThe input could not be processed\nPossible reason: An unmatched `<` may be in the input, replace all unmatched `<` with `<lt>`\n%s'):format(category,create_backtrace(test))
                instance.handler.error(msg)
            elseif errmsg~='' then
                local msg=('test(%s) errord:\n%s\n%s'):format(category,errmsg,create_backtrace(test))
                if msg:find'\0' then
                    msg=vim.re.gsub(msg,'[\0]','\\0')
                end
                instance.handler.error(msg)
                -- When a test errors, it is slow, and one errord test typically means multiple errord tests
                -- So we don't stop test execution here so that the test execution doesn't take so long
                return 'error'
            elseif get_lines_and_pos(instance,test.trim)~=test[3] then
                local msg=('test(%s) failed\n%s'):format(category,create_backtrace(test,get_lines_and_pos(instance,test.trim)))
                instance.handler.error(msg)
            end
            ::continue::
        end
    end
end

local M={}
M.tests=list_of_tests
M._dont_rec_check=dont_rec_check

---@param plugin_path string?
---@param handler ua.health.handler?
---@param dev boolean?
function M.run_tests(plugin_path,handler,dev)
    handler=handler or require'ultimate-autopair.health'.default_handler

    handler.start('Running tests')

    if not plugin_path then
        local lua_path=vim.api.nvim_get_runtime_file('lua/ultimate-autopair',false)[1]
        if not lua_path then
            handler.error('Could not find ultimate-autopair plugin path')
            return
        end
        plugin_path=vim.fs.dirname(vim.fs.dirname(lua_path))
    end

    if vim.fn.executable(vim.v.progpath)==0 then
        handler.error('`v:progpath` is not executable')
        return
    end

    if (vim.fn.systemlist({vim.v.progpath,'--version'})[1]~=vim.api.nvim_exec2('version',{output=true}).output:gsub('\n.*$','')) then
        handler.warn(("The first line in `:version` didn't match `:!%s --version`"):format(vim.v.progpath))
    end

    local instance=create_instance(handler)
    instance:exec_lua('vim.opt.runtimepath:append(...)',plugin_path)

    instance:exec_lua('_UA_IN_TEST=true',plugin_path)

    instance:exec_lua[[
    vim['lg']=function (...)
        local d=debug.getinfo(2)
        return vim.fn.writefile(vim.fn.split(
            ':'..d.short_src..':'..d.currentline..':\n'..
            vim.inspect(#{...}==1 and ... or {...}),'\n'
        ),'/tmp/nlog','a')
    end]]

    local conf_tests=get_tests_by_config(handler,dev)
    for _,tests in pairs(conf_tests) do
        if run_tests(instance,tests)=='error' then
            handler.warn('Unrecoverable error happened: Prematurely stopping test execution')
            break
        end
    end
    if vim.fn.jobstop(instance._chan)==0 then
        handler.error('Could not stop test execution')
    end
end

return M
