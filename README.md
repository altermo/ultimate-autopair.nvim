###### :exclamation: Ultimate-autopair is _alpha_ software. Some things may change, and some things may break. Documentation may sometimes be inaccurate.
# Ultimate-autopair.nvim 0.4.0
Ultimate-autopair plugin aims to have <u style="color: red">**all possible features**</u> that an auto-pairing plugin needs.

Note that the documentation is severely out of date.

Requires neovim 0.7
## Summary
Ultimate-autopair is a neovim autopair plugin that is easy to extend, by the fact that it supports extensions. (Note that the extra mappings (`<CR>`,`<BS>`,...) currently use a different system of extensions) The builtin extensions includes among other things: command line support, multicharacter pairs, non one-line, fastwarp and much more...
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
## Default-configuration
```lua
mapopt={noremap=true},
cmap=true,
bs={
    enable=true,
    overjump=true,
    space=true,
    multichar=true,
    fallback=nil,
    extensions=require('ultimate-autopair.maps.bs').default_extensions,
},
cr={
    enable=true,
    autoclose=false,
    multichar={
        enable=false,
        markdown={{'```','```',pair=true,noalpha=true,next=true}},
        lua={{'then','end'},{'do','end'}},
    },
    addsemi={'c','cpp','rust'},
    fallback=nil,
    extensions=require('ultimate-autopair.maps.cr').default_extensions,
},
space={
    enable=true,
    fallback=nil,
},
fastwarp={
    enable=true,
    hopout=false,
    map='<A-e>',
    rmap='<A-E>',
    Wmap='<A-C-e>',
    cmap='<A-e>',
    rcmap='<A-E>',
    Wcmap='<A-C-e>',
    multiline=true,
    fallback=nil,
    extensions=require('ultimate-autopair.maps.fastwarp').default_extensions,
    endextensions=require('ultimate-autopair.maps.fastwarp').default_endextensions,
    rextensions=require('ultimate-autopair.maps.rfastwarp').default_extensions,
    rendextensions=require('ultimate-autopair.maps.rfastwarp').default_endextensions,
},
fastend={
    enable=true,
    map='<A-$>',
    cmap='<A-$>',
    smart=false,
    fallback=nil,
},
_default_beg_filter=M.default_beg_filter,
_default_end_filter=M.default_end_filter,
extensions={
    {'cmdtype',{'/','?','@'}},
    'multichar',
    'string',
    {'treenode',{inside={'comment'}}},
    'escape',
    'rules',
    'filetype',
    {'alpha',{before={"'"}}},
    {'suround',{'"',"'"}},
    {'fly',{')','}',']',' ',match=nil}},
},
internal_pairs={
    {'(',')'},
    {"'","'",rules={{'when',{'option','lisp'},{'instring'},{'not',{'filetype','tex'}}}}},
    rules={ --only runs if the extension rules is loaded
        {[[\']],[[\']],rules={{'and',{'not',{'or',{'next',"'"},{'previous','\\',2}}},{'instring'}}}},
        {[[\"]],[[\"]],rules={{'and',{'not',{'or',{'next','"'},{'previous','\\',2}}},{'instring'}}}},
    },
    ft={
        markdown={
            {'```','```'},
            {'<!--','-->'},
        },
        ---more...
    },
    ---more...
},
----Place own pairs here...
--{'$$','$$'},
```
## The extensions
<!--| indentblock   | makes the block of indent the "line" instead of it the current line-->
| Extension     | What it does
| ------------- | -
| cmdtype       | disables for specific command types
| string        | makes it so that inside and outside of strings don't interact with each other (treesitter support)
| multichar     | allows for pairs which consist of multiple characters
| escape        | don't add if it will be escaped
| rules         | a system which allows one to add rules
| filetype      | only allow some file types
| alpha         | no pair before or after alpha character
| surround      | auto surround the pair `\|"foo"`>`(`>`("foo"\|)`
| fly           | fly over ending parentheses `([{\|}])` > `)` > `([{}])\|`
| treenode      | filter inside or outside treesitter nodes
### Other plugins to supercharge auto-pairing
These are some other plugins which are related to pairing which have features that ultimate-autopair does not.
+ [endwise](https://github.com/RRethy/nvim-treesitter-endwise) wisely add `end` in lua, ruby, etc...
+ [tabout](https://github.com/abecodes/tabout.nvim) tab out of parentheses
+ [surround](https://github.com/kylechui/nvim-surround) delete, change surrounding parentheses and much more...
+ [autotag](https://github.com/windwp/nvim-ts-autotag) auto add html tags
### Donate
If you want to donate then you need to find the correct link (50₁₀):
* [0a]() [0b]() [0c]() [0d]() [0e]() [0f]() [0g]() [0h]()
* [1a]() [1b]() [1c]() [1d]() [1e]() [1f]() [1g]() [1h]()
* [2a]() [2b]() [2c]() [2d]() [2e]() [2f]() [2g]() [2h]()
* [3a]() [3b]() [3c]() [3d]() [3e]() [3f]() [3g]() [3h]()
* [4a]() [4b]() [4c]() [4d]() [4e]() [4f]() [4g]() [4h]()
* [5a]() [5b]() [5c]() [5d]() [5e]() [5f]() [5g]() [5h]()
* [6a]() [6b](https://www.buymeacoffee.com/altermo) [6c]() [6d]() [6e]() [6f]() [6g]() [6h]()
* [7a]() [7b]() [7c]() [7d]() [7e]() [7f]() [7g]() [7h]()
