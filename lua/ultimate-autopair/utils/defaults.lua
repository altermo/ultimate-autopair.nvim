local utils=require'ultimate-autopair.utils.utils'
local M={}
function M.default_end_filter(o,_,_,gmem)
    if not gmem[o.key] then
        return 2
    end
    local add_pair=require'ultimate-autopair.utils.add_pair'
    return add_pair.pair(o.pair,o.paire,o.line,o.col,o.wline,o.wcol,o.type)
end
function M.default_beg_filter(o,_,_,gmem)
    o.extra={}
    if gmem[o.key] then o.pair=gmem[o.key].pair end
    if gmem[o.key] then o.paire=gmem[o.key].paire end
    if gmem[o.key] then o.type=gmem[o.key].type end
    o.line=utils.getline()
    o.wline=utils.getline()
    o.col=utils.getcol()
    o.wcol=utils.getcol()
    o.linenr=utils.getlinenr()
    o.cmdmode=utils.incmd()
end
M.default_config={
    mapopt={noremap=true},
    cmap=true,
    bs={
        enable=true,
        overjump=true,
        space=true,
        multichar=true,
        fallback=nil,
    },
    cr={
        enable=true,
        autoclose=true,
        multichar={
            markdown={{'```','```',pair=true,noalpha=true,next=true}},
            lua={{'then','end'},{'do','end'}},
        },
        fallback=nil,
    },
    space={
        enable=true,
        fallback=nil,
    },
    fastwarp={
        enable=true,
        map='<A-e>',
        cmap='<A-e>',
        fallback=nil,
    },
    _default_beg_filter=M.default_beg_filter,
    _default_end_filter=M.default_end_filter,
    extensions={
        {'cmdtype',{'/','?','@'}},
        --'indentblock',
        'multichar',
        'string',
        'escape',
        'rules',
        'filetype',
        {'alpha',{before={"'"}}},
        {'suround',{'"',"'"}},
        {'fly',{')','}',']',' '}},
    },
    {'[',']'},
    {'(',')'},
    {'{','}'},
    {'"','"'},
    {"'","'",rules={{'when',{'filetype','lisp'},{'instring'}}}},
    {'`','`'},
    rules={
        {[[\']],[[\']],rules={{'not',{'or',{'next',"'"},{'previous','\\',2}}}}},
        {[[\"]],[[\"]],rules={{'not',{'or',{'next','"'},{'previous','\\',2}}}}},
    },
    ft={
        markdown={
            {'```','```'},
            {'<!--','-->'},
        },
        css={{'<!--','-->'}},
        c={{'/*','*/'}},
        cpp={{'/*','*/'}},
        cs={{'/*','*/'}},
        go={{'/*','*/'}},
        java={{'/*','*/'}},
        javascript={{'/*','*/'}},
        jsonc={{'/*','*/'}},
        rust={{'/*','*/'}},
        typescript={{'/*','*/'}},
        python={
            {'"""','"""'},
            {"'''","'''"},
        },
    },
}
return M
