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
        _func='default',
    },
    cr={
        enable=true,
        map='<cr>', --string or table
        cmap='<cr>',
        autoclose=false,
        --addsemi={'c','cpp','rust'},
        _func='default',
    },
    space={
        enable=true,
        map=' ',
        cmap=' ',
        check_box_ft={'markdown','vimwiki'},
        _func='default',
    },
    fastwarp={
        enable=true,
        hopout=false,
        map='<A-e>',
        rmap='<A-E>',
        cmap='<A-e>',
        rcmap='<A-E>',
        multiline=true,
        _func='default',
        nocursormove=true,
    },
    extensions={
        cmdtype={types={'/','?','@'},p=90},
        string={p=80},
        treenode={inside={'comment'},p=70},
        escape={filter=true,p=60},
        rules={p=50},
        filetype={p=40,nft={'TelescopePrompt'}},
        alpha={p=30},
        suround={p=20},
        fly={other_char={' '},nofilter=false,p=10,undu_map='<C-b>'},
    },
    internal_pairs={
        {'[',']',fly=true,dosuround=true,newline=true,space=true,fastwarp=true,backspace_suround=true},
        {'(',')',fly=true,dosuround=true,newline=true,space=true,fastwarp=true,backspace_suround=true},
        {'{','}',fly=true,dosuround=true,newline=true,space=true,fastwarp=true,backspace_suround=true},
        {'"','"',suround=true,rules={{'when',{'filetype','vim'},{'not',{'regex','^%s*$'}}}}},
        {"'","'",suround=true,rules={{'when',{'option','lisp'},{'instring'}}},alpha=true,nft={'tex'}},
        {'`','`',nft={'tex'}},
        {'``',"''",ft={'tex'}},
        {'```','```',newline=true,ft={'markdown'}},
        {'<!--','-->',ft={'markdown','html'}},
        {'"""','"""',newline=true,ft={'python'}},
        {"'''","'''",newline=true,ft={'python'}},
    },
}
return M
