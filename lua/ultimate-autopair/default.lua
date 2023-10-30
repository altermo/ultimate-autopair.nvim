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
    single_delete=false,
    -- <!--|--> > bs > <!-|
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
    conf={cond=function(fn) return not fn.in_lisp() end},
    --contains extension config
    multi=false,
    --use multiple configs (|ultimate-autopair-map-multi-config|)
  },
  space={-- *ultimate-autopair-map-space-config*
    enable=true,
    map=' ', --string or table
    cmap=' ', --string or table
    check_box_ft={'markdown','vimwiki','org'},
    _check_box_ft2={'norg'}, --may be removed
    --+ [|] > space > + [ ]
    conf={},
    --contains extension config
    multi=false,
    --use multiple configs (|ultimate-autopair-map-multi-config|)
  },
  space2={-- *ultimate-autopair-map-space2-config*
    enable=false,
    match=[[\k]],
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
    no_filter_nodes={'string','raw_string','string_literals','character_literal'},
    --which nodes to skip for tsnode filtering
    faster=false,
    --only enables jump over pair, goto end/next line
    --useful for the situation of:
    --{|}M.foo('bar') > {M.foo('bar')|}
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
    do_nothing_if_fail=true,
    --add a module so that if close fails
    --then a `)` will not be inserted
  },
  tabout={-- *ultimate-autopair-map-tabout-config*
    enable=false,
    map='<A-tab>', --string or table
    cmap='<A-tab>', --string or table
    conf={},
    --contains extension config
    multi=false,
    --use multiple configs (|ultimate-autopair-map-multi-config|)
    hopout=false,
    -- (|) > tabout > ()|
    do_nothing_if_fail=true,
    --add a module so that if close fails
    --then a `\t` will not be inserted
  },
  extensions={-- *ultimate-autopair-extensions-default-config*
    cmdtype={skip={'/','?','@','-'},p=100},
    filetype={p=90,nft={'TelescopePrompt'},tree=true},
    escape={filter=true,p=80},
    utf8={p=70},
    tsnode={p=60,separate={'comment','string','raw_string',
      'string_literals','character_literal','line_comment','block_comment','nesting_block_comment'}}, -- #62
    cond={p=40,filter=true},
    alpha={p=30,filter=false,all=false},
    suround={p=20},
    fly={other_char={' '},nofilter=false,p=10,undomapconf={},undomap=nil,undocmap=nil,only_jump_end_pair=false},
  },
  internal_pairs={-- *ultimate-autopair-pairs-default-pairs*
    {'[',']',fly=true,dosuround=true,newline=true,space=true},
    {'(',')',fly=true,dosuround=true,newline=true,space=true},
    {'{','}',fly=true,dosuround=true,newline=true,space=true},
    {'"','"',suround=true,multiline=false},
    {"'","'",suround=true,cond=function(fn) return not fn.in_lisp() or fn.in_string() end,alpha=true,nft={'tex'},multiline=false},
    {'`','`',cond=function(fn) return not fn.in_lisp() or fn.in_string() end,nft={'tex'},multiline=false},
    {'``',"''",ft={'tex'}},
    {'```','```',newline=true,ft={'markdown'}},
    {'<!--','-->',ft={'markdown','html'}},
    {'"""','"""',newline=true,ft={'python'}},
    {"'''","'''",newline=true,ft={'python'}},
  },
  config_internal_pairs={-- *ultimate-autopair-pairs-configure-default-pairs*
    --configure internal pairs
    --example:
    --{'{','}',suround=true},
  },
}
return M
