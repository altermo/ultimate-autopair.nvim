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
<!--TODO-->
### Toggle the plugin
Use `require'ultimate-autopair'.toggle()`
### Disable in comment
<!--TODO Recommended is `{extensions={tsnode={outside={'comment'},p=50,filter=true}}}` \
Note: some languages don't detect the node containing comment as `comment` in a weird way, use `:=vim.treesitter.get_node({}):type()` to get the actual node type (I will fix this later).-->
### Disable in macros
<!--TODO-->

## Why questions about update
### Why was `UTF8` moved to the core
Cause it was incompatible with multiline editing. The problem is that transforming o.col to usable column is not the easiest. There's a functionality for this but it was easier to implement UTF8 into core.
### Why was `rule` extension removed and replaced with `cond` extension
It was a bad idea to create conditions using lisp language, making other things harder
### Why was `string` extension removed and replaced with `tsnode` detection
Because multi-line in pair detection is slow, at leas how it is currently set up: I got that in_pair was called a few thousand times, and even when I implemented cache, it was still to slow. (If anyone knows a good solution, pleas post report)
