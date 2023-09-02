# This is a collection of all the issue questions, updated to the latest release
Ones own choice is ALWAYS prefixed with `your_`.

## General questions
### How to update to latest release
1. Remove ultimate-autopair.nvim from plugin manager install list
2. Clean plugins (so that ultimate-autopair.nvim is completely removed)
3. Add ultimate-autopair.nvim back to plugin manager install list
### How to disable in command line
Use `{cmap=true}`.
### How to disable in specific filetype
Use `{extensions={filetype={nft={'your_filetype'}}}}`.
### How to enable extension.fly in quotes (in string)
To enable fly for quotes, use `{config_internal_pairs={{'"','"',fly=true},{"'","'",fly=true}}}`
To "enable" fly in string (as quotes are often string), use `{extensions={fly={nofilter=true}}}`
### How to create undo map for extension.fly
Use `{extensions={fly={undomap='your_map'}}}`
### How to only balance space when non space character inserted
If you want to to do that, recommended is `{space={enable=false},space2={enable=true}}`
### How to set multiple mapping for, for example, backspace
Use `{bs={map={'your_map1','your_map2'}}}`
### How to disable the plugin in lisp
Use `{extensions={cond={cond=function(fn) return not fn.in_lisp() end}}}`
### How to toggle the plugin
Use `require'ultimate-autopair'.toggle()`
### How to disable in comment
Use `{extensions={cond={cond=function(fn) return not fn.in_node('comment') end}}}`
### How to disable in macros
Use `{extensions={cond={cond=function(fn) return not fn.in_macro() end}}}`
### How to disable hop over end pair
For already exsisting pairs, use `{config_internal_pairs={{'(',')',disable_end=true}}}`
For new pairs, use `{{'<','>',disable_end=true}}`
### How to disable in replace mode
To disable in replace mode, use `{extensions={cond={cond=function(fn) return fn.get_mode()~='R' end}}}`
