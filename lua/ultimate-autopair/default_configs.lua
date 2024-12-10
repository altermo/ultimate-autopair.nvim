local comment_nodes={
  'comment',
  'line_comment','block_comment','nesting_block_comment' --d #62
}
local stringish_nodes={
  'string','char','character',
  'raw_string', --fish/bash/sh
  'char_literal','string_literal', --c/cpp
  'string_value', --css
  'str_lit','char_lit', --clojure/commonlisp
  'interpreted_string_literal','raw_string_literal','rune_literal', --go
  'quoted_attribute_value', --html
  'template_string', --javascript
  'LINESTRING','STRINGLITERALSINGLE','CHAR_LITERAL', --zig
  'string_literals','character_literal', --d #62
}
local comment_and_stringish_nodes={
  'comment','string','char','character',
  'raw_string', --fish/bash/sh
  'char_literal','string_literal', --c/cpp
  'string_value', --css
  'str_lit','char_lit', --clojure/commonlisp
  'interpreted_string_literal','raw_string_literal','rune_literal', --go
  'quoted_attribute_value', --html
  'template_string', --javascript
  'LINESTRING','STRINGLITERALSINGLE','CHAR_LITERAL', --zig
  'string_literals','character_literal','line_comment','block_comment','nesting_block_comment' --d #62
}

---@param con ua.context.pos
---@return boolean
local function in_lisp(con)
  --TODO: if `use_filetype_getopt` is false then have a preset list of filetypes which are lisp
  local filterlib=require'ultimate-autopair.filterlib'
  return (not filterlib.in_lisp(con)) or filterlib.in_any_node(con,comment_and_stringish_nodes)
end
return {
  _default_comment_nodes=comment_nodes,
  _default_stringish_nodes=stringish_nodes,
  _default_comment_and_stringish_nodes=comment_and_stringish_nodes,
  main_config={
    map_modes={'i','c'},
    pair_map_modes=nil, --If nil then same as `map_modes`
    multiline=true,
    -- enables use of `vim.filetype.get_option`, which may break other plugins
    use_filetype_getopt=false,
    {'(',')'},
    {'[',']'},
    {'{','}'},
    {'"','"',multiline=false,nft={'tex'}},
    {{"'",alpha={before=true,py_fstr=true,lua_nstr=true}},"'",
      --[[filter_on_insert=in_lisp TODO]]multiline=false,nft={'tex','rust'}},
    --{'<!--','-->',ft={'markdown','html'}}, --TODO: temp
    --{'"""','"""',ft={'python'}}, --TODO: temp
    --{"'''","'''",ft={'python'}}, --TODO: temp
    --{'```','```',ft={'markdown'}}, --TODO: temp
    filter={
      cmdtype={skip={'/','?','@'}},
      escape={},
      alpha={},
      filetype={nft={'TelescopePrompt'},detect_after=true,treesitter=true},
      --tsnode={separate=comment_and_stringish_nodes}, --TODO
    },
    integration={
      endwise=true,
    },
    backspace={
      enable=true,
      map='<bs>',
      fallback='<bs>',
      ---@param con ua.context.pos
      overjump=function (con)
        --If pair is ambiguous(start and end are same) then don't overjump
        if con.pair and con.pair.is_ambiguous then
          return false
        end
        return true
      end
    },
    newline={
      enable=true,
      map='<cr>',
      fallback='<cr>',
    },
    space={
      enable=false,
      map='<space>',
      fallback='<space>',
    },
    fastwarp={
      type='normal',
      enable=false,
      fallback='',
      map='<A-e>',
      rmap='<A-E>',
    },
    fastwarp_treesitter={
      type='treesitter',
      enable=false,
      fallback='',
      map={'<A-C-e>',p=10},
      rmap={'<A-C-E>',p=10},
    },
    fastwarp_fast={
      type='fast',
      enable=false,
      fallback='',
      map='<A-C-e>',
      rmap='<A-C-E>',
    },
  }
}
--- vim:shiftwidth=2:expandtab:
