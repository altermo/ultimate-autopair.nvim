**:exclamation: Ultimate-autopair is at the moment in the _beta_ stage of development. ([versioning system](https://github.com/altermo/ultimate-autopair.nvim/blob/v0.6/CONTRIBUTING.md#version))**
# Ultimate-autopair.nvim 0.6.1
[Ultimate-autopair](https://github.com/altermo/ultimate-autopair.nvim) plugin aims to always work as you expect and be ultra customizable, while making it easy to configure. It has features which other auto-pairing plugins lack: multiline support, treesitter-node filtering and treesitter-filetype detection.

For development version, which is sometimes up to date with default branch, check out [development](https://github.com/altermo/ultimate-autopair.nvim/tree/development)\
Requires **neovim 0.9** (for older versions of neovim, check previous versions of plugin)\
For some features, including string filtering, requires **treesitter**.

For new users, check out starter documentation (`:help ultimate-autopair`)
## Installation
<details open=true><summary><b>Lazy</b></summary>

```lua
{
    'altermo/ultimate-autopair.nvim',
    event={'InsertEnter','CmdlineEnter'},
    branch='v0.6', --recommended as each new version will have breaking changes
    opts={
        --Config goes here
    },
}
```
</details><details><summary><b>Packer</b></summary>

```lua
use{
    'altermo/ultimate-autopair.nvim',
    event={'InsertEnter','CmdlineEnter'},
    branch='v0.6', --recommended as each new version will have breaking changes
    config=function ()
        require('ultimate-autopair').setup({
                --Config goes here
                })
    end,
}
```
</details>

## Default configuration
For the default configuration, refer to the documentation (`:help ultimate-autopair-default-config`).
## Demo
</details><details> <summary><b>demo</b></summary>

![demo](https://github.com/altermo/ultimate-autopair.nvim/assets/107814000/a30ba4fd-0a3b-49af-bcd8-67413c9a86d1)
</details>

### Other plugins to supercharge auto-pairing
These are some other plugins which are related to pairing which have features that ultimate-autopair does not have.
+ [endwise](https://github.com/RRethy/nvim-treesitter-endwise) wisely add `end` in lua, ruby, etc... (Note: doesn't get broken by ultimate-autopair's newline)
+ [tabout](https://github.com/abecodes/tabout.nvim) tab out of treesitter nodes
+ [surround](https://github.com/kylechui/nvim-surround) delete, change surrounding parentheses and much more...
+ [autotag](https://github.com/windwp/nvim-ts-autotag) auto pair html tags

If you want to use this together with [nvim-autopairs](https://github.com/windwp/nvim-autopairs) read `:h ultimate-autopair-use-with-npairs`

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
