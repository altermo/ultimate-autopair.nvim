local in_lisp=function (fn)
  return not fn.in_lisp() or fn.in_string() or fn.in_comment()
end
--local markdown={
  --ts_not_after={'latex_block','code_span','fenced_code_block'}
--}
return {
  conf={
    map_modes={'i','c',merge=false},
    pair_map_modes=nil,
    multiline=true,
    {'(',')'},
    {'[',']'},
    {'{','}'},
    {'"','"',multiline=false},
    {"'","'",start_pair={alpha={before=true,py_fstr=true}},multiline=false},
    {'`','`',filter={filter=in_lisp},multiline=false},
    {'```','```',ft={'markdown'}},
    {'<!--','-->',ft={'markdown','html'}},
    {'"""','"""',ft={'python'}},
    {"'''","'''",ft={'python'}},
    filter={
      alpha={},
      cmdtype={skip={'/','?','@'}},
      filter={p=-1},
      escape={},
      filetype={nft={'TelescopePrompt'},lang_detect_after=true},
      tsnode={p=-2,lang_detect_after=true,separate={'comment','string','char','character',
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
        local info=obj.info
        --If pair is ambiguous then don't overjump
        if info and info.main_pair and info.start_pair==info.pair.start_pair then
          return false
        end
        return true
      end
    },
    newline={
      enable=true,
      map='<cr>',
    },
    space={
      enable=false,
      map='<space>',
    },
  },
  --TODO:
  --tex={
  --disable={
  --ft='tex',
  --{"'","'"},
  --{'`','`'},
  --},
  --set_or_change={
  --ft='tex',
  --{'``',"''"},
  --{'$','$'},
  --{'\\[','\\]'},
  ----{'$$','$$'},
  --}
  --},
  --markdown={
  --set_or_change={
  --ft='markdown',
  --{'`','`',tsnode={ft='markdown',lang_detect='after insert',not_after={'latex_block','fenced_code_block'}}},
  --{'*','*',tsnode={ft='markdown',lang_detect='after insert',not_after=markdown.ts_not_after}},
  --{'_','_',tsnode={ft='markdown',lang_detect='after insert',not_after=markdown.ts_not_after}},
  --{'__','__',tsnode={ft='markdown',lang_detect='after insert',not_after=markdown.ts_not_after}},
  --{'**','**',tsnode={ft='markdown',lang_detect='after insert',not_after=markdown.ts_not_after}},
  --{'$','$',tsnode={ft='markdown',lang_detect='after insert',not_after={'code_span','fenced_code_block'}}},
  --{'~~','~~',tsnode={ft='markdown',lang_detect='after insert',not_after=markdown.ts_not_after}},
  ----{'***','***',tsnode={ft='markdown',lang_detect='after insert',not_after=markdown.ts_not_after}},
  ----{'___','___',tsnode={ft='markdown',lang_detect='after insert',not_after=markdown.ts_not_after}},
  --}
  --},
  --rust_default_include={
  --change={
  --ft='rust',
  --{"'","'",tsnode={not_after={'lifetime','label'}}},
  --},
  --},
  --rust={
  --set_or_change={
  --ft='rust',
  --{'<','>',
  --tsnode={not_after={ft='rust','arrow_function','binary_expression','augmented_assignment_expression'}},
  --multiline=function (fn) return fn.treesitter_enabled() end,
  --},
  --}
  --},
  --lua_default_include={
  --change={
  --ft='lua',
  --{"'","'",alpha_before={tsnode={ft='lua',not_after={'string'}}}},
  --},
  --},
  --lua={
  --{'%[=-%[','%]=-%]',type='patter',ft='lua'},
  --},
  --comment={
  --{function (o)
  --local utils=require'ultimate-autopair.utils'
  --local comment=utils.ft_get_option(utils.get_filetype_after_insert(utils.to_filter(o),'´'),'commentstring') --[[@as string]]
  --local pair={comment:match('(.+)%%s(.+)')}
  --return #pair>0 and pair or nil
  --end,type='callable'}
  --},
}
--- vim:shiftwidth=2:expandtab:
