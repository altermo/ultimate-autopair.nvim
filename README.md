###### :exclamation: Ultimate-autopair is _alpha_ software. Some things may change and some things may break. Documentation may sometimes be inaccurate.
# Ultimate-autopair.nvim 0.2.4
Ultimate-autopair plugin aims to have <u style="color: red">**all possible features**</u> that an auto-pairing plugin needs.

Requires neovim 0.7
## Summary
Ultimate-autopair is an auto-pairing plugin that is easy to extend, by the fact that it supports extensions. (Note that the extra mappings (`<CR>`,`<BS>`,...) currently do **not** use this system of extensions) The builtin extensions includes among other things: command line support, multicharacter pairs, non one-line, fastwarp and much much more...
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
},
cr={
    enable=true,
    autoclose=true,
    multichar={
        markdown={{'```','```',pair=true,noalpha=true,next=true}},
        lua={{'then','end'},{'do','end'}},
    },
    addsemi={'c','cpp','rust'},
    fallback=nil,
},
space={
    enable=true,
    fallback=nil,
},
fastwarp={
    enable=true,
    map='<A-e>',
    cmap='<A-e>',
    fallback=nil,
},
_default_beg_filter=M.default_beg_filter,
_default_end_filter=M.default_end_filter,
extensions={
    {'cmdtype',{'/','?','@'}},
    --'indentblock',
    'multichar',
    'string',
    'escape',
    'rules',
    'filetype',
    {'alpha',{before={"'"}}},
    {'suround',{'"',"'"}},
    {'fly',{')','}',']',' '}},
},
{'(',')'},
{"'","'",rules={{'when',{'option','lisp'},{'instring'}}}},
rules={ --only runs if the extension rules is loaded
    {[[\']],[[\']],rules={{'not',{'or',{'next',"'"},{'previous','\\',2}}}}},
    {[[\"]],[[\"]],rules={{'not',{'or',{'next','"'},{'previous','\\',2}}}}},
},
ft={
    markdown={
        {'```','```'},
        {'<!--','-->'},
    },
    ---more...
},
---more...
```
## The extensions
| Extension   | What it does
|-------------|-
| cmdtype     | disables for specific command types
| indentblock | makes the block of indent the "line" instead of it the current line
| string      | makes it so that inside and outside of strings don't interact with each other (treesitter support)
| multichar   | allows for pairs which consist of multiple characters
| escape      | don't add if it will be escaped
| rules       | a system which allows one to add rules
| filetype    | only allow some file types
| alpha       | no pair before or after alpha character
| surround    | auto surround the pair `\|"foo"`>`(`>`("foo"\|)`
| fly         | fly over ending parentheses `([{\|}])` > `)` > `([{}])\|`
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
