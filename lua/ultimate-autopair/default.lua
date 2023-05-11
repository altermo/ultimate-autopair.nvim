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
    },
    cr={
        enable=true,
        map='<cr>', --string or table
        autoclose=false,
        --addsemi={}, --list of filetypes
    },
    space={
        enable=true,
        map=' ',
        cmap=' ',
        check_box_ft={'markdown','vimwiki'},
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
        --nocursormove=true,
        do_nothing_if_fail=true,
    },
    extensions={
        cmdtype={types={'/','?','@'},p=90},
        filetype={p=80,nft={'TelescopePrompt'}},
        escape={filter=true,p=70},
        string={p=60},
        --treenode={inside={'comment'},p=50},
        rules={p=40},
        alpha={p=30},
        suround={p=20},
        fly={other_char={' '},nofilter=false,p=10,undu_map='<C-b>'},
    },
    internal_pairs={
        {'[',']',fly=true,dosuround=true,newline=true,space=true,fastwarp=true,backspace_suround=true},
        {'(',')',fly=true,dosuround=true,newline=true,space=true,fastwarp=true,backspace_suround=true},
        {'{','}',fly=true,dosuround=true,newline=true,space=true,fastwarp=true,backspace_suround=true},
        {'"','"',suround=true,rules={{'when',{'filetype','vim'},{'not',{'regex','^%s*$'}}}},string=true},
        {"'","'",suround=true,rules={{'when',{'option','lisp'},{'instring'}}},alpha=true,nft={'tex'},string=true},
        {'`','`',nft={'tex'}},
        {'``',"''",ft={'tex'}},
        {'```','```',newline=true,ft={'markdown'}},
        {'<!--','-->',ft={'markdown','html'}},
        {'"""','"""',newline=true,ft={'python'}},
        {"'''","'''",newline=true,ft={'python'}},
        {'string',type='tsnode',string=true},
    },
}
return M
