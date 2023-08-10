--Static
local M={}
---@type prof.config
M.conf={
    profile='default',
    --what profile to use
    map=true,
    --whether to allow any insert map
    cmap=true, --cmap stands for cmd-line map
    --whether to allow any cmd-line map
    pair_map=true,
    --whether to allow pair insert map
    pair_cmap=true,
    --whether to allow pair cmd-line map
    multiline=true,
    --enable/disable multiline
    bs={-- *ultimate-autopair-map-backspace-config*
        enable=true,
        map='<bs>', --string or table
        cmap='<bs>', --string or table
        overjumps=true,
        --(|foo) > bs > |foo
        space=true, --false, true or 'balance'
        --( |foo ) > bs > (|foo)
        --balance:
        --  Will prioritize balanced spaces
        --  ( |foo  ) > bs > ( |foo )
        indent_ignore=false,
        --(\n\t|\n) > bs > (|)
        conf={},
        --contains extension config
        multi=false,
        --use multiple configs (|ultimate-autopair-map-multi-config|)
    },
    cr={-- *ultimate-autopair-map-newline-config*
        enable=true,
        map='<cr>', --string or table
        autoclose=false,
        --(| > cr > (\n|\n)
        --addsemi={}, --list of filetypes
        conf={},
        --contains extension config
        multi=false,
        --use multiple configs (|ultimate-autopair-map-multi-config|)
    },
    space={-- *ultimate-autopair-map-space-config*
        enable=true,
        map=' ', --string or table
        cmap=' ', --string or table
        check_box_ft={'markdown','vimwiki'},
        --+ [|] > space > + [ ]
        conf={},
        --contains extension config
        multi=false,
        --use multiple configs (|ultimate-autopair-map-multi-config|)
    },
    space2={-- *ultimate-autopair-map-space2-config*
        enable=false,
        match=[[\a]],
        --what character activate
        conf={},
        --contains extension config
        multi=false,
        --use multiple configs (|ultimate-autopair-map-multi-config|)
    },
    fastwarp={-- *ultimate-autopair-map-fastwarp-config*
        enable=true,
        enable_normal=true,
        enable_reverse=true,
        hopout=false,
        --{(|)} > fastwarp > {(}|)
        map='<A-e>', --string or table
        rmap='<A-E>', --string or table
        cmap='<A-e>', --string or table
        rcmap='<A-E>', --string or table
        multiline=true,
        --(|) > fastwarp > (\n|)
        nocursormove=true,
        --makes the cursor not move (|)foo > fastwarp > (|foo)
        --disables multiline feature
        --only activates if prev char is start pair, otherwise fallback to normal
        do_nothing_if_fail=true,
        --add a module so that if fastwarp fails
        --then an `e` will not be inserted
        filter_string=false,
        --whether to use builting filter string
        conf={},
        --contains extension config
        multi=false,
        --use multiple configs (|ultimate-autopair-map-multi-config|)
    },
    close={-- *ultimate-autopair-map-close-config*
        enable=true,
        map='<A-)>', --string or table
        cmap='<A-)>', --string or table
        conf={},
        --contains extension config
        multi=false,
        --use multiple configs (|ultimate-autopair-map-multi-config|)
    },
    extensions={-- *ultimate-autopair-extensions-default-config*
        cmdtype={skip={'/','?','@'},p=100},
        filetype={p=90,nft={'TelescopePrompt'},tree=true},
        escape={filter=true,p=80},
        string={p=60,tsnode={'string','raw_string'},nopair=true},
        --cond={p=40,filter=false},
        --alpha={p=30,filter=false},
        --suround={p=20},
        --fly={other_char={' '},nofilter=false,p=10,undomapconf={},undomap=nil,undocmap=nil,only_jump_end_pair=false},
    },
    internal_pairs={-- *ultimate-autopair-pairs-default-pairs*
        {'[',']',fly=true,dosuround=true,newline=true,space=true,fastwarp=true},
        {'(',')',fly=true,dosuround=true,newline=true,space=true,fastwarp=true},
        {'{','}',fly=true,dosuround=true,newline=true,space=true,fastwarp=true},
        {'"','"',suround=true,string=true,fastwarp=true,multiline=false},
        {"'","'",suround=true,cond=function(fn) return fn.ft()~='lisp' or fn.instring() end,alpha=true,nft={'tex'},string=true,fastwarp=true,multiline=false},
        {'`','`',nft={'tex'},fastwarp=true,multiline=false},
        {'``',"''",ft={'tex'}},
        {'```','```',newline=true,ft={'markdown'}},
        {'<!--','-->',ft={'markdown','html'}},
        {'"""','"""',newline=true,ft={'python'},string=true},
        {"'''","'''",newline=true,ft={'python'},string=true},
    },
    config_internal_pairs={-- *ultimate-autopair-pairs-configure-default-pairs*
        --configure internal pairs
        --example:
        --{'{','}',suround=true},
    },
}
return M
