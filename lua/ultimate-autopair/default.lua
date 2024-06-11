local in_lisp=function (o)
  local fn=require'ultimate-autopair._lib.filter' --TODO: better name
  return (not fn.in_lisp(o)) or fn.in_string(o) or fn.in_comment(o)
end
--local markdown={
--  ts_not_after={'latex_block','code_span','fenced_code_block'}
--}
return {
  conf={
    map_modes={'i','c'},
    pair_map_modes=nil,
    multiline=true,
    {'(',')'},
    {'[',']'},
    {'{','}'},
    {'"','"',multiline=false,nft={'tex'}},
    {"'","'",start_pair={alpha={before=true,py_fstr=true}},filter={in_lisp},multiline=false,nft={'tex','rust'}},
    {'`','`',filter={in_lisp},multiline=false},
    {'<!--','-->',ft={'markdown','html'}}, --TODO: temp
    {'"""','"""',ft={'python'}}, --TODO: temp
    {"'''","'''",ft={'python'}}, --TODO: temp
    {'```','```',ft={'markdown'}}, --TODO: temp
    filter={
      cmdtype={skip={'/','?','@'}},
      escape={},
      alpha={p=-8},
      filetype={p=-9,nft={'TelescopePrompt'},lang_detect_after=true},
      tsnode={p=-10,lang_detect_after=true,separate={'comment','string','char','character',
        'raw_string', --fish/bash/sh
        'char_literal','string_literal', --c/cpp
        'string_value', --css
        'str_lit','char_lit', --clojure/commonlisp
        'interpreted_string_literal','raw_string_literal','rune_literal', --go
        'quoted_attribute_value', --html
        'template_string', --javascript
        'LINESTRING','STRINGLITERALSINGLE','CHAR_LITERAL', --zig
        'string_literals','character_literal','line_comment','block_comment','nesting_block_comment' --d #62
      }},
    },
    extension={
      --surround={},
      --fly={},
    },
    integration={
      autotag={},
      endwise={},
    },
    backspace={
      enable=true,
      map='<bs>',
      overjump=function (_,obj)
        ---@cast obj ua.prof.pair.pair
        --If pair is ambiguous then don't overjump
        if obj and obj.ispair and obj.end_pair_old==obj.start_pair_old then
          return false
        end
        return true
      end
    },
    newline={
      modes={'i'},
      enable=true,
      map='<cr>',
    },
    space={
      enable=false,
      map='<space>',
    },
    fastwarp={
      enable=true,
      map='<A-e>',
    }
  },
  --tex={
  --  {'``',"''",ft='tex'},
  --},
  --python={
  --  {'"""','"""',ft={'python'}},
  --  {"'''","'''",ft={'python'}},
  --},
  --markdown={
  --  {'```','```',ft={'markdown'},tsnode={ft='markdown',lang_detect='after insert',not_after={'latex_block','fenced_code_block'}}},
  --  {'*','*',ft={'markdown'},tsnode={ft='markdown',lang_detect='after insert',not_after=markdown.ts_not_after}},
  --  {'_','_',ft={'markdown'},tsnode={ft='markdown',lang_detect='after insert',not_after=markdown.ts_not_after}},
  --  {'__','__',ft={'markdown'},tsnode={ft='markdown',lang_detect='after insert',not_after=markdown.ts_not_after}},
  --  {'**','**',ft={'markdown'},tsnode={ft='markdown',lang_detect='after insert',not_after=markdown.ts_not_after}},
  --  {'$','$',ft={'markdown'},tsnode={ft='markdown',lang_detect='after insert',not_after={'code_span','fenced_code_block'}}},
  --  {'~~','~~',ft={'markdown'},tsnode={ft='markdown',lang_detect='after insert',not_after=markdown.ts_not_after}},
  --  --{'***','***',ft={'markdown'},tsnode={ft='markdown',lang_detect='after insert',not_after=markdown.ts_not_after}},
  --  --{'___','___',ft={'markdown'},tsnode={ft='markdown',lang_detect='after insert',not_after=markdown.ts_not_after}},
  --},
  --comment={
  --  {'%[=-%[','%]=-%]',type='patter',ft='lua'},
  --  {function (o)
  --    local utils=require'ultimate-autopair.utils'
  --    local comment=utils.ft_get_option(utils.get_filetype_after_insert(utils.to_filter(o),'´'),'commentstring') --[[@as string]]
  --    local pair={comment:match('(.+)%%s(.+)')}
  --    return #pair>0 and pair or nil
  --  end,type='callable',nft={'lua'}}
  --}
}
--- vim:shiftwidth=2:expandtab:
