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
