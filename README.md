# Ultimate-autopair.nvim 0.7.0
[Ultimate-autopair](https://github.com/altermo/ultimate-autopair.nvim) plugin aims to have any most features you want and be ultra customizable, while making it easy to configure.
## Major features
+ Treesitter node filtering and treesitter injected language(filetype) detection
+ Multiline support (and caching)
+ The configuration system to rule them all:
    + Smart merge with default configuration
    + Smart inherit from parent config
    + Validate that the configuration is correct
    + Some options are runtime options and can be set to function to dynamically calculate them
    + Generate a random config (cause why not)
+ Mappings
    + backspace
        + `(|)` > `|`
    + newline
        + `(|)` > `(\n|\n)`
    + space
        + `(|foo)` > `( |foo )`
        +  Previous versions had a space2 which was refactored into space, please read `:h todo`
    + fastwarp and reverse fastwarp
        + `(|)foo` > `(|foo)`
        + works multiline: `(|){foo\nbar}` > `({foo\nbar})`
    + close
        + `(|` > `(|)`
    + tabout
        + `(f|oo)` > `(foo|)`
+ Extensions
    + surround
        + `|"foo"` > `(` > `(|"foo")`
    + fly
        + `({[|]})` > `)` > `({[]})|`
+ UTF-8 compatible (or at leasts tries to be)
+ Extensiv testing
+ Terminal and normal mode support
+ And much much more...
## Use
+ If your planing to use this with `rust`: `:h ultimate-autopair-use-with-rust`
+ If your planing to use this with `latex`: `:h ultimate-autopair-use-with-latex`
+ If your planing to use this with `lisp`: `:h ultimate-autopair-use-with-lisp`
+ If your planing to use this with `html`: `:h ultimate-autopair-use-with-html`
## Install
Minimum Neovim version: 0.9.2; Recommended: 0.10 (or 0.11-dev)\
(Neovim versions 0.9.1<= (and 0.10-dev) had bugs which could crache Neovim (see: [neovim/neovim#24796](https://github.com/neovim/neovim/pull/24796)))
<details open=true><summary><b>Lazy</b></summary>

```lua
{
    'altermo/ultimate-autopair.nvim',
    event={'InsertEnter','CmdlineEnter'}, -- initialization is slow so lazyloading is recommended
    branch='v0.7', --recommended as each new version will have breaking changes
    opts={
        --Config goes here
    },
    dependencies={
        -- -- Optional dependencies
        -- 'nvim-treesitter/nvim-treesitter',
        -- -- For installing parsers which will be used to get nodes and injected filetypes
        -- 'windwp/nvim-ts-autotag',
        -- -- html tag integration (IMPORTANT: read `:h ultimate-autopair-use-with-html`)
    }
}
-- -- Recommended but not exactly related to ultimate-autopair
-- 'gpanders/nvim-parinfer',
-- -- the parinfer algorithm for LISP programming
-- 'RRethy/nvim-treesitter-endwise',
-- -- Auto add `end` keyword for some languages
-- 'abecodes/tabout.nvim',
-- -- Treesitter based more complex tabout (if ultimate-autopair's tabout is not good enough)
-- 'kylechui/nvim-surround',
-- -- Surround selected with pairs, delete/change surrounding pairs (in normal/visual mode)
```
</details>

<details><summary><b>Without plugin-manager</b></summary>

```lua
local install_dir=vim.fn.stdpath('data')..'/plugins'
vim.fn.mkdir(install_dir,'p')
for _,url in ipairs{
    'altermo/ultimate-autopair.nvim',
    --'nvim-treesitter/nvim-treesitter',
} do
    local install_path=install_dir..'/'..url:gsub('.*/','')
    if vim.fn.isdirectory(install_path)==0 then
        vim.fn.system{'git','clone','https://github.com/'..url,install_path}
    end
    vim.opt.runtimepath:append(install_path)
end

-- require'nvim-treesitter.configs'.setup{}

-- initialization is slow so lazyloading is recommended
local au_id
au_id=vim.api.nvim_create_autocmd({'InsertEnter','CmdlineEnter'},{callback=function()
    require('ultimate-autopair').setup{
        --config
    }
    pcall(vim.api.nvim_del_autocmd,au_id)
end})
```
</details>

## Issues
### Run health checks
If things doesn't work, try running `:checkhealth ultimate-autopair` to see if there are any errors/warnings.
This doesn't run all health checks, only the ones related to the user.
To run all health checks (including develeopmental ones), run `:lua _G.UA_DEV=true` and then run `:checkhealth ultimate-autopair`.
If this reports any errors (which the normal health check doesn't), then it is probably a bug and should be reported (though there are some exceptions).
### Keymap conflict
Ultimate-autopair uses these insert-keymaps by default: `<A-e>`, `<A-S-e>`, `<BS>`, `<CR>`, `<A-)>` (+ the pair keymaps).
Some plugins handle these keymap conflicts well, and no no extra config is needed.
If you don't use the features that the keymaps are for then disable them in the config. (see `:h ultimate-autopair-default-config`)
If you use the features that the keymaps are for but still want to use them for other things then look into `:h ultimate-autopair-fallback` and `:h ultimate-autopair-create-map`
### Filetype not detecting
Treesitter is used to detect injected filetypes, but the process is not perfect:
To convert between treesitter languages and filetypes, one uses `vim.treesitter.language.get_filetypes(lang)`, but some treesitter languages correspond to multiple filetypes, and to not deal with the concept of multiple filetypes in one region, a treesitter language to singular filetype table is used (see `require'ultimate-autopair.utils'.tslang2lang`).

### Donate
If you want to donate then you need to find the correct link (hint: 50₁₀):
* [0a]() [0b]() [0c]() [0d]() [0e]() [0f]() [0g]() [0h]()
* [1a]() [1b]() [1c]() [1d]() [1e]() [1f]() [1g]() [1h]()
* [2a]() [2b]() [2c]() [2d]() [2e]() [2f]() [2g]() [2h]()
* [3a]() [3b]() [3c]() [3d]() [3e]() [3f]() [3g]() [3h]()
* [4a]() [4b]() [4c]() [4d]() [4e]() [4f]() [4g]() [4h]()
* [5a]() [5b]() [5c]() [5d]() [5e]() [5f]() [5g]() [5h]()
* [6a]() [6b](https://www.buymeacoffee.com/altermo) [6c]() [6d]() [6e]() [6f]() [6g]() [6h]()
* [7a]() [7b]() [7c]() [7d]() [7e]() [7f]() [7g]() [7h]()
### Chat
+ [github discussions](https://github.com/altermo/ultimate-autopair.nvim/discussions)
<!-- + [matrix](https://matrix.to/#/#ultimate-autopair.nvim:matrix.org)-->
