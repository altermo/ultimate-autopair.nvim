**:exclamation: Ultimate-autopair is currently in the _alpha_ stage of development. Some aspects may change or break, and documentation might occasionally be inaccurate.**
# Ultimate-autopair.nvim 0.6.0-pre-alpha


[Ultimate-autopair](https://github.com/altermo/ultimate-autopair.nvim) plugin aims to always work as you expect, while making it relatively easy to configure.\
For development version, check out [development](https://github.com/altermo/ultimate-autopair.nvim/tree/development)\
Requires **neovim 0.9** (for older versions of neovim, check previous versions of plugin)\
For many features, including string filtering, requires **treesitter**.
## changelog of version 0.6
<details open=true><summary><b>BREAKING CHANGES</b></summary>

If your coming from a previous version with broken config, check out [Q&A](./Q&A.md) first
+ `string` extension is no longer enabled by default (uses treesitter-string filtering instead).
    + If you want to use `string` extension, find answer in [Q&A](./Q&A.md)
+ `rule` extension got removed in favour of new extension `cond`
+ `sub` extension got removed until a better solution can be found
</details><details><summary><b>New features</b></summary>

+ New extension `cond`: create conditions
+ You can now use multiline
</details><details><summary><b>Improvements</b></summary>

+ Tests now run 1000% faster
+ The code got cleaned up
+ `tabout` was moved from experimental to default (requires manual enable)
</details>

## Installation
<details open=true><summary><b>Packer</b></summary>

```lua
use{
    'altermo/ultimate-autopair.nvim',
    event={'InsertEnter','CmdlineEnter'},
    config=function ()
        require('ultimate-autopair').setup({
                --Config goes here
                })
    end,
}
```
</details><details> <summary><b>Lazy</b></summary>

```lua
{
    'altermo/ultimate-autopair.nvim',
    event={'InsertEnter','CmdlineEnter'},
    opts={
        --Config goes here
    },
}
```
</details>

## Features
+ Smart open pair detecting:
  + TODO
+ multiline and multichar pair support:
  + TODO
## Default configuration
For the default configuration, refer to the documentation (`:help ultimate-autopair-config-default`).
### Other plugins to supercharge auto-pairing
These are some other plugins which are related to pairing which have features that ultimate-autopair does not have.
+ [endwise](https://github.com/RRethy/nvim-treesitter-endwise) wisely add `end` in lua, ruby, etc...
+ [tabout](https://github.com/abecodes/tabout.nvim) tab out of tsnode objects
+ [surround](https://github.com/kylechui/nvim-surround) delete, change surrounding parentheses and much more...
+ [autotag](https://github.com/windwp/nvim-ts-autotag) auto add html tags
+ <a href="https://github.com/windwp/nvim-autopairs">nvim-autopairs</a> integration: Use [npairs-integrate-upair](https://github.com/altermo/npairs-integrate-upair) with `require('npairs-int-upair').setup({map='u'})`

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
+ [matrix](https://matrix.to/#/#ultimate-autopair.nvim:matrix.org)
