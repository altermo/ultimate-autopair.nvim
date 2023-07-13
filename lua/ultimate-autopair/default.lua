local M={}
M.conf={
    config_type='default',
    map=true,
    cmap=true, --cmap stands for cmd-line map
    pair_map=true,
    pair_cmap=true,
    bs={
        enable=true,
        map='<bs>', --string or table
        cmap='<bs>', --string or table
        overjumps=true,
        space=true, --false, true or 'balance'
        indent_ignore=false,
        conf={},
        multi=false,
    },
    cr={
        enable=true,
        map='<cr>', --string or table
        autoclose=false,
        --addsemi={}, --list of filetypes
        conf={},
        multi=false,
    },
    space={
        enable=true,
        map=' ', --string or table
        cmap=' ', --string or table
        check_box_ft={'markdown','vimwiki'},
        conf={},
        multi=false,
    },
    space2={
        enable=false,
        match=[[\a]],
        conf={},
        multi=false,
    },
    fastwarp={
        enable=true,
        enable_normal=true,
        enable_reverse=true,
        hopout=false,
        map='<A-e>', --string or table
        rmap='<A-E>', --string or table
        cmap='<A-e>', --string or table
        rcmap='<A-E>', --string or table
        multiline=true,
        nocursormove=true,
        do_nothing_if_fail=true,
        filter_string=false,
        conf={},
        multi=false,
    },
    close={
        enable=true,
        map='<A-)>', --string or table
        cmap='<A-)>', --string or table
        conf={},
        multi=false,
    },
    extensions={
        cmdtype={types={'/','?','@'},p=100},
        filetype={p=90,nft={'TelescopePrompt'}},
        escape={filter=true,p=80},
        utf8={p=70,map=nil},
        string={p=60},
        rules={p=40,rules=nil},
        alpha={p=30},
        suround={p=20},
        fly={other_char={' '},nofilter=false,p=10,undomapconf={},undomap=nil,undocmap=nil,only_jump_end_pair=false},
    },
    internal_pairs={
        {'[',']',fly=true,dosuround=true,newline=true,space=true,fastwarp=true},
        {'(',')',fly=true,dosuround=true,newline=true,space=true,fastwarp=true},
        {'{','}',fly=true,dosuround=true,newline=true,space=true,fastwarp=true},
        {'"','"',suround=true,string=true,fastwarp=true},
        {"'","'",suround=true,rules={{'when',{'option','lisp'},{'instring'}}},alpha=true,nft={'tex'},string=true,fastwarp=true},
        {'`','`',nft={'tex'},fastwarp=true},
        {'``',"''",ft={'tex'}},
        {'```','```',newline=true,ft={'markdown'}},
        {'<!--','-->',ft={'markdown','html'}},
        {'"""','"""',newline=true,ft={'python'},string=true},
        {"'''","'''",newline=true,ft={'python'},string=true},
        {'string',type='tsnode',string=true},
        {'raw_string',type='tsnode',string=true},
    },
    config_internal_pairs={
    },
}
return M
