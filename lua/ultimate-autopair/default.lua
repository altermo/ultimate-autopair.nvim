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
        cmap='<bs>',
        overjumps=true,
        space=true,
        indent_ignore=false,
        conf={},
    },
    cr={
        enable=true,
        map='<cr>', --string or table
        autoclose=false,
        --addsemi={}, --list of filetypes
        conf={},
    },
    space={
        enable=true,
        map=' ',
        cmap=' ',
        check_box_ft={'markdown','vimwiki'},
        conf={},
    },
    space2={
        enable=false,
        match=[[\a]],
        conf={},
    },
    fastwarp={
        enable=true,
        enable_normal=true,
        enable_reverse=true,
        hopout=false,
        map='<A-e>',
        rmap='<A-E>',
        cmap='<A-e>',
        rcmap='<A-E>',
        multiline=true,
        nocursormove=true,
        do_nothing_if_fail=true,
        filter=false,
        conf={},
    },
    extensions={
        cmdtype={types={'/','?','@'},p=90},
        filetype={p=80,nft={'TelescopePrompt'}},
        escape={filter=true,p=70},
        string={p=60},
        --treenode={inside={'comment'},p=50},
        rules={p=40,rules=nil},
        alpha={p=30},
        suround={p=20},
        fly={other_char={' '},nofilter=false,p=10,undomapconf={},undomap=nil,undocmap=nil},
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
        {'"""','"""',newline=true,ft={'python'}},
        {"'''","'''",newline=true,ft={'python'}},
        {'string',type='tsnode',string=true},
        {'raw_string',type='tsnode',string=true},
    },
}
return M
