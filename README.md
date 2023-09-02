**:exclamation: Ultimate-autopair is currently in the _alpha_ stage of development. Some aspects may change or break, and documentation might occasionally be inaccurate.**
# Ultimate-autopair.nvim 0.6.0
[Ultimate-autopair](https://github.com/altermo/ultimate-autopair.nvim) plugin aims to always work as you expect, while making it relatively easy to configure. It has many features which other auto-pairing plugins lack: like multiline support, string/escape filtering and more. It is fully tested and has good docs.

For development version, check out [development](https://github.com/altermo/ultimate-autopair.nvim/tree/development)\
Requires **neovim 0.9** (for older versions of neovim, check previous versions of plugin)\
For many features, including string filtering, requires **treesitter**.\
:exclamation: If your coming  from `v0.5.3` and want to update: remove the plugin totally and reinstall.

For new users, check out starter documentation (`:help ultimate-autopair`)
## changelog of version 0.6.0
<details open=true><summary><b>BREAKING CHANGES</b></summary>

If your coming from a previous version with broken config, check out [Q&A](./Q&A.md) first
+ `string` extension got removed in favour of `tsnode` string node detection
+ `rule` extension got removed in favour of new extension `cond`
+ `sub` extension got removed until a better solution can be found
</details><details><summary><b>Major new features</b></summary>

+ New extension `cond`: create conditions
+ You can now use multiline
+ `tabout` was moved from experimental to default (requires manual enable)
</details><details><summary><b>Major code improvements</b></summary>

+ Tests now run over 1000% faster
+ Most things are type-hinted
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

## Default configuration
For the default configuration, refer to the documentation (`:help ultimate-autopair-config-default`).
## Demo
<!--TODO: add better demo-->
</details><details> <summary><b>demo</b></summary>

![demo](https://github.com/altermo/ultimate-autopair.nvim/assets/107814000/a30ba4fd-0a3b-49af-bcd8-67413c9a86d1)
</details>

### Other plugins to supercharge auto-pairing
These are some other plugins which are related to pairing which have features that ultimate-autopair does not have.
+ [endwise](https://github.com/RRethy/nvim-treesitter-endwise) wisely add `end` in lua, ruby, etc...
+ [tabout](https://github.com/abecodes/tabout.nvim) tab out of tsnode objects
+ [surround](https://github.com/kylechui/nvim-surround) delete, change surrounding parentheses and much more...
+ [autotag](https://github.com/windwp/nvim-ts-autotag) auto add html tags
+ <a href="https://github.com/windwp/nvim-autopairs">nvim-autopairs</a> integration: read `:h ultimate-autopair-use-with-npairs`

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
