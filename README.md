**:exclamation: Ultimate-autopair is currently in the _alpha_ stage of development. Some aspects may change or break, and documentation might occasionally be inaccurate.**
# Ultimate-autopair.nvim 0.5.3
Ultimate-autopair plugin aims to provide all the features that an auto-pairing plugin needs.\
For development version, check out [development](https://github.com/altermo/ultimate-autopair.nvim/tree/development)\
For the next version, check out [v0.6.0](https://github.com/altermo/ultimate-autopair.nvim/tree/v0.6.0)\
Requires neovim 0.8 (recomended 0.9)
## Installation
Packer:
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
## Configuration
To add a pair, use the syntax `ua.setup{{'<<','>>'},}`.
For more configuration options, refer to the documentation (`:help ultimate-autopair-config-default`).
### Other plugins to supercharge auto-pairing
These are some other plugins which are related to pairing which have features that ultimate-autopair does not have.
+ [endwise](https://github.com/RRethy/nvim-treesitter-endwise) wisely add `end` in lua, ruby, etc...
+ [tabout](https://github.com/abecodes/tabout.nvim) tab out of parentheses
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
