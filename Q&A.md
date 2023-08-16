# This is a collection of all the issue questions, updated to the latest release
Ones own choice is ALWAYS prefixed with `your_`.

## Questions for updating
### If somethings really not working
I have maybe accidentally done something weird with `git`, which causes it to not update, so before posting an issue, try this:
1. Remove ultimate-autopair.nvim from plugin manager install list
2. Clean plugins (so that ultimate-autopair.nvim is completely removed)
3. Add ultimate-autopair.nvim back to plugin manager install list
### Disable in command line
Use `{cmap=true}`.
### Disable in specific filetype
Use `{extensions={filetype={nft={'your_filetype'}}}}`.
### Enable extension.fly in quotes (in string)
To enable fly for quotes, use `{config_internal_pairs={{'"','"',fly=true},{"'","'",fly=true}}}`
To "enable" fly in string (as quotes are often string), use `{extensions={fly={nofilter=true}}}`
### Create undo map for extension.fly
Use `{extensions={fly={undomap='your_map'}}}`
### Only balance space when non space character inserted
If you want to to do that, recommended is `{space={enable=false},space2={enable=true}}`
### Set multiple mapping for, for example, backspace
Use `{bs={map={'your_map1','your_map2'}}}`
### Disable the plugin in lisp
Use `{extensions={cond={cond=function(fn) return not fn.in_lisp() end}}}`
### Toggle the plugin
Use `require'ultimate-autopair'.toggle()`
### Disable in comment
Use `{extensions={cond={cond=function(fn) return fn.get_tsnode_type()~='comment' end}}}`\
NOTE: in markdown, comments have the ts type `html_block`.\
If you want to detect those use:\
`{extensions={cond={cond=function(fn) return fn.get_tsnode_type()~='comment' and fn.get_tsnode_type()~='html_block' end}}}`

### Disable in macros
Use `{extensions={cond={cond=function(fn) return not fn.in_macro() end}}}`

## Why questions about update
### Why was `rule` extension removed and replaced with `cond` extension
It was a bad idea to create conditions using lisp language, making other things harder
### Why was `string` extension removed and replaced with `tsnode` detection
Because multi-line in pair detection is slow, at leas how it is currently set up: I got that in_pair was called a few thousand times, and even when I implemented cache, it was still to slow. (If anyone knows a good solution, pleas post report)
