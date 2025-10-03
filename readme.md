# Ultimate-autopair 0.7
NOTE: some features of 0.6 are still not implemented yet...

## The Sales pitch
Do you hate when there's pairing even though there's clearly a non-closed end pair in the next line?
Do you want a fast way to surround an object with a pair?
Do you want endless and easy configuration?
Welcome to [Ultimate-autopair](https://github.com/altermo/ultimate-autopair.nvim), a Neovim plugin which aims to:
+ Make auto-pairing less annoying (smart and multiline-pairing).
+ Make surrounding text with a pair easy and fast (fastwarp).
+ Be easy and enjoyable to configure (full lua-annotations and config validation)
+ Have ultimate customization (e.x. if you only want fastwarp, you can disable everything else)
+ Be fast (exception: treesitter features, as the treesitter parser can be slow)
+ Have many features (e.x. dynamic pairs)

## Differences from previous versions
### Backspace
<!-- TODO: Don't remove this opting in the final version -->
Removed `space` option
can be replaced with this config:
```lua
{
  -- Define a "pair"
  {
    -- Each part of the pair can either be a string or a table
    {
      -- The first key is the hooks, the thing that triggers the pairing
      -- Can be string or a list of hooks
      -- An empty table is a list of hooks with no hooks, so will never trigger
      {},

      -- The second key is the acutall pair
      -- Can be string or a function which generates the pair
      ---@param con ua.context
      ---@param fns ua.utils.fns
      ---@return string,string
      function (con,fns)
        -- The `fns.start_match` function is a QOL to handle matching start pairs
        -- It takes three (not two) arguments
        -- The third one is the last character of the start pair, which is needed
        --  because the last character is not always present
        --  e.x. pair `<a>` and `</a>`, and you are at `<a` then the match need to
        --  use `<a` instead of `<a>`
        local start_pair=fns.start_match(con,('[({] *',' ')
        local end_pair_char=({['(']=')',['{']='}'})[start_pair:sub(1)]

        -- Don't worry about subpairs, it is handled automatically
        return start_pair,start_pair:sub(2)..end_pair_char
      end
    },
    {
      {},
      ---@param con ua.context
      ---@param fns ua.utils.fns
      ---@return string,string
      function (con,fns)
        -- There's never a situation where the first character of the end pair
        --  is not present, so we only need two arguments
        local end_pair=fns.end_match(con,(' +[)}]')
        local start_pair_char=({[')']='(',['}']='{'})[end_pair:sub(-1)]
        return start_pair_char..end_pair:sub(1,-2),end_pair
      end
    },

    -- Don't inherit any options from the base, such as filter and map options
    inherit=false,

    backspace={
      -- Except for backspace
      inherit=true,
    },
    filter={
      -- And filter
      inherit_root_filters=true,
    }
  }
}
```

# 
# Rust
For lifetime `<'a>` and `&'a`, it is recommended to use config:
```lua
change={"'","'",filter={alpha_multi={{before='[<&]',filter={filetype={ft='rust'}}}}}}
```

# Init
```lua
-- PLEASE READ THE INFO
{
  -- use `vim.filetype.get_option`
  -- triggers filetype event's which may break things
  use_filetype_getopt=true,
}
```

<!-- vim: set ts=2 sw=2: -->
