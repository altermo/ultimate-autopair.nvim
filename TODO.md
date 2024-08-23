## TODO (later)
+ smart pair finder:
    1. create a table where some pairs are mapped to other pairs which substring is that pair, and offsets and whatnot
        + for example `"("={"\(",col=2} , '"'={'""',col=1}, '"',={'""',col=2}`
    2. when matching pair, check if any bigger pair matches that (using the col offset and filtering) and if so, don't count it to the count
    + this will be useful because someone can make a pair `{'\(',')'}` and things like `|\()` > `(` > `(|)\()` (e.g. will not be broken)
    + but what about: config: `{'(',')'},{'(',')/'}` and then `()(|)/` > `<bs>` > `()|/` instead of `()|`
        + basically, `{'(',')/'}` matches all `(` without a corresponding `)/` as open (which is most `(` as they a typically matched with `)`)
+ make it so that the configuration is dynamically merged/inhereted:
    + only merge/inherit the things that are needed at the the initialization time
        + this will speed up initialization
    + when something is needed at runtime, then merge/inherit it
+ New map: normal mode follow pair: basically when this is run, go to normal mode, but the pair after the cursor follows the cursor (using some extmarks), and then when entering insert mode, place the pair after the cursor
    + Demo (`[]` is normal cursor) `(|)a` > `esc` > `([)]a` > `l` > `(a[)]` > `a` `(a)|`
+ refactor api to make it easier to use to create new modules
    + also documentation
+ allow creation of mappings which interact with pairs
    + so that created maps can use find_correspodning_pair or similar
        + the reason why arbitrary mappings don't work is because there can be multiple configs with multiple pairs
+ SMART INDENT (when fastwarp, backspace, space, ...) [example](https://shaunlebron.github.io/parinfer/)
+ Make ext.surround be able to create keymap, which toggles the surround. (Basically fastwarp/reverse fastwarp automatic detect)
+ ext.fly:
    + remove unbalanced spaces
    + hop multiple lines (and remove lines containing only or empty)
## DONE
+ make ext.tsnode work for non default-profile-pairs (like matchparen)
+ dont separate pair and global extension configs: merge them instead
    + and an option to not merge
    + and an option for using user specified table merger
+ make it so that pair wise configuration rewrites/merges (depending on pair config `merge=*`) with the extension config instead of them being needed to be handled separately.
    + Make this also work for mappings (like `bs` and other) somehow
+ remove default enable space
+ How to handle when cursor on border with two nodes
+ use query instead of for looping (example: `vim.treesitter.query.parse('lua','(string) @string')`)
+ separately enable space and space2
    + make space and space2 use the same function (internally) for space amount detection (and maybe even space backspace)
+ Go through all treesitter parsers, and add all the exceptions where the treesitter parser name is not the same as the filetype name
    + Also treesitter parsers which may be multiple filetypes
+ separate filters (configs) for start and end pairs, like alpha `a|` > `'` > `a'|` but `'a|'` > `''` > `'a'|`
+ when using smartft and not in injected lang, use default vim.o.filetype even if treesitter is active
+ pair with arbitrary length/content
+ make the isolated tsnode types filetype specific (as a possibility)
+ When filtering, filter the whole pair, instead of just the cursor:
    + Example `pair=\(,\)` `\|` > `(` > `\(|\)`
+ move the tests somewhere else (because checkhealth shouldn't do tests)
    + maybe do it so that if UA_DEV is set then checkhealth do tests (do this one)
+ if in filetype lua, then only activate alpha_before if in string or comment
+ replace all `vim.list_contains` with `vim.tbl_contains` (because of compatibility with neovim 0.9)
+ hook.lua handle both input and output
+ use `typos` to spell check everything and add to breaking change that wrongly spelled arguments are corrected
+ in the option `.change` it is easy to accidentally not do an array of pairs, but instead do a single pair, and the user gets a weird and hard to understand error, so make it so that it instead becomes an understandable and logical error
    + basically do a full validation in `.change` option (using an array of pairs as option value, (not main config type))
+ make `map` and `raw` profile be able to set priority (or make a function that produces objects and requires a priority as an argument)
## TODO (half done)
+ make it so that instead of sending keybindning/autocmds, send what to do when and make the hook modulo deal with it.
    + instead of sending `InsertChar` and then check for alpha, send `multimap,sets.alpha` and it will handle it automatically
    + Makes it possible to easily change the implementation of hook to allow other things
+ IMPORTANT!!!!!!!!!!!! SOME PARSER DO NOT SET IS_VALID AND THUS ALWAYS REPARSE ON :PARSE, SO SAVE THE INFO ABOUT IT BEING PARSED SEPARATELY
    + FOR PERFORMANCE: IF TREESITTER HIGHLIGHTING ENABLED AND PARSER IN A TABLE WHICH ASURES THAT THE PARSER IS UPP TO DATE WHEN THE TREESITTER HIGHLIGHTING IS ENABLED, THEN SKIP PARSING
+ use `nvim_buf_attach` or `LanguageTree:register_cbs` if using treesitter (important as this will run after the treesitter parser has parsed the buffer, rather than instantly) to precalculate/cache specific lines/ranges
+ make cache work with treesitter
+ fastwarp/close/tabout/other implement `do_nothing_if_fail` (or something similar)
+ do a maximum user configuration validation on checkhealth
## TODO (before release)
+ check that all the todos were done
+ check that all the features from v0.6 are still working
+ what about the `notes` files? (maybe move them here)
+ github change description before new release
+ look through the hole readme
+ look through the hole documentation
+ increase 0.6.1 > 0.6.2 before release of 0.7.0
+ make sure that in all places where node types are used, one can make them filetype specific
+ make sure that everything is documented
+ fix all typos
+ got through all bug reports, and create a test case for the ones that need it
+ add info to 0.6.2's readme about how there's a new version (e.g. 0.7)
+ make sure that all the test were imported from 0.6
+ make sure that all the options from v0.6 are still somewhat represented in v0.7 (e.g. look through v0.6 `default.lua` and see if all the options have a represented option in v0.7)
+ MAKE ABSULUTELY SURE THAT IT WORKS WITH NEOVIM VERSION 0.9.0
+ Where to put the open_pair.lua file?
+ start working on refining other plugins (e.g. iedit.nvim)
## TODO (now)
+ html tags [link](https://www.reddit.com/r/neovim/comments/167xgag/comment/jz8d5th/?context=3)
+ be able to disable extensions depending on filters (like surround extension in rust)
### TODO (document)
+ document everything
+ Make a better documentation
    + Make it clear how to make pairs
    + and make intermal_pairs > __internal_pairs --If you want to create your own pairs: link
+ add config_internal_pairs to the example config in the readme
    + and also rename it to something else
+ readme:
    + add info about adding filetype pairs
        + more specifically, about the supported filetypes
            + like mardown, tex
            + and a note like, if you are using markdown, check out `:h ultimate-autopair-markdown-pairs` for preconfigurerd pairs
        + and link to list of supported filetypes
        + and a default set of filetype pairs
    + [x] add info about how to install and lazyload without plugin manager (eg using nvim_create_autocmd with once=true)
    + [x] add info to troubleshoot about how it uses `vim.filetype.get_option` (and how it sources `ftplugin` files (which may be case breakage))
    + add info to troubleshoot about how string/comment nodes may differ between parsers and that not all of the nodes are saved
    + [x] add info to troubleshoot about running `:checkhealth` (and with _G.UA_DEV set)
    + [x] add info to troubleshoot about treesitter language vs filetype
    + add info to troubleshoot about needing treesitter parsers installed (but thing like highlighting not needed to be enabled)
    + add info to troubleshoot about how some pairs are disabled in some filetypes
    + add info to troubleshoot about how merging is not done for list of strings (or something similar)
+ add doc about how the things are set up:
    1. Configurations will be parsed by a configuration parser.
        + If such parser/parsers exist.
        + `init.setup` will use `init.extend_default`.
    2. All previously defined hooks(mappings,autocmds,other) are cleared for the instance.
        + If the instance has not previously defined hooks, don't do anything.
    3. All configurations are passed to their respective profiles (`profile=*`)
        + `init.setup` will use `default` profile.
    4. The profiles will generate modules from the configurations and add them to `mem`.
        + `mem` is a list of modules, each instance has one.
    5. The specified hook system creates hooks for the modules.
+ add doc about how the things are run:
    1. The hook system catches an action
    2. The hook system looks up which modules wanted to hook into the action.
    3. The hook system recalls the action to the modules until one of them returns an action.
        + If no module returns an action, a fallback is used.
    4. The action is sent to the editor
+ add doc about the different kinds of `o` and what they have as keys
+ doc
    + Add doc about unique mapping
    + ctrl-w support: just use `{bs={map={'<C-w>','<bs>'}}}`
+ document all the functions in `_lib/filter.lua` (and mention it in the readme)
+ document how to use identetyless filters:
    + what the fields of `o` are
    + how to use the helper library functions
### TODO (config/inheritance)
+ make config be auto called when index
    `conf=setmetatable({},{__index=function (opt) return orof(opt,m) end})`
    + except for function arguments
        + except except `dynamic_call=true` (or something similar)
+ Option to disable filetype.get_option for specific filetypes
+ Be able to add simple `id=*` to make the user have the ability to identefy the mapping if there are multiple of the same type.
    + Useful for example `ext_cond` and function based options.
    + Also maybe have a way to only rewrite/merge options depending on `id`, and make a module be able to have multiple ids for easier configuration.
+ ext.cond, make the in_string() use a global option
    + that global option should also be passed to default config
    + BASICALLY: make it easy to define string and comment and other node type collections
        + with some of them only working for some filetypes
        + maybe? be able to have more complicated queries
            + use the builtin query system instead for a separate query file as an option for the user
+ Also a config validation option for verbose messages:
    + When true, don't just print the path to the incorrect option but also it's parent and parent parent option (so that it is easier to find)
    + in the validation config message, include the mention of using verbosed config validation messages for better debug
+ for confspec: make (internal) `validate()` return either nil or a list of args which can be used to construct an error message rather than just raising an error message:
    + this is useful for an `or` statement, where it could check one side, and if it fails then check the other side, and if both fail then construct an error message: `The option $traceback should be EITHER $expected1 OR $EXPECTED2 but it has the value $VALUE [which has the type $TYPE]`
    + for example, the `The option "map.cond" should be EITHER "of type function" OR "one of values {'a','b'}" but it has the value "'&'" which has the type "string"`
    + maybe a better system could be used.
        + like not allowing two different types of specifications (so no mixing istype and isenum)
+ option for `validate()` to raise error upon the value being an option-table value (so that when an `or` is found, then one side should never be a option-table)
+ `config.validation` have 4 options:
    + `none`: dont validate
    + `fast`: only do basic type checiking, even for enums
    + `normal`: enum checking, but no advanced checking
    + `slow`: advanced checking (like whether all tsnode-types are valid)
    + `warnerr`: even set wrong things that might be right (like using a filetype as an option while treesitter is enabled, and the neovim tslang to filetype converter includes that filetype but the plugin one doesn't)
+ config: make the map option be able to take a (or multiple) hook(s)(table(s)) as input
+ confspec: for some config specifications, be able to set docs...
    + and a health check that each config option has att least one doc (doc can be inherited (though this is not recommended))
    + the generated docs should also include the default value
        + or if it inherits from another config, what it inheres from (and a note that that other config may inhertit from another config)
+ confspec: for some config specifications, be able to set inheritance...
    + example: `{pair_map_modes={__inherit_config='.map_modes',__base='modes'}}`; can't use `__inherit_keys` because of reasons
    + `.` at beginning means from root, `:` is parent
    + use caching and other things to optimize this
+ confspec: for some config specifications, be able to set if they are optional or required
    + make it so that all options need to be set either of the two (don't presume that it is by default optional/required)
    + if something is marked as optional, then it can be nil
    + if something is marked as required, then it can't be nil
    + this check should be done in the validation step
+ confspec: if UA_DEV set, then make it so that runtime options are by default set to a newproxy which contains a metatable which contains the actual value, so that usage of this newproxy results in an error (or something similar so that all runtime options are resolved correctly)
+ confspec: how to make runtime options resolve correctly? For example, that the passed in position is correct...
+ TO THE README: add documentation about which mappings are created by default
+ TO THE README: add documentation about how it will fallback to previously set mappings
+ TO THE README: add info about how `cr` -> `newline` and `bs` -> `backspace`
+ Validate that the multiple version (of fore example mappings or filters) have a main version (maybe?)
+ TO THE README: use atension grabbing quotes
+ confspec: what about being able to set some options to false to disable them? (this should be validated also and handled correctly)
+ in config validation: make a distinction between a value being able to be nil and a value needing to be set
    + this is non-trivial because the value may be nil initially, but after inheritance it may not be
### TODO (test)
+ `_lib.filter.term_in_shell_or_vim`
+ `_lib.filter.in_node`
+ that `map.modes={...}` works
+ that newline doesn't create a keymap in cmdline mode
+ that pair local map options work (like `{'(',')',backspace={map={'h'}}}`)
+ test that filetype specific configurations work (both if pairs are enabled and if they are disabled)
+ test that multiple filters/maps work
+ test that maps in pair config work (or make it so that you can't set the specific map in the pair config)
+ add tests which tests that endwise and ts-autotag works
+ Create treesitter-endwise specific tests
+ Create a smart test case where multiple pairs can easily be tested at the same time
    + Example: `{'%s|%s',' ','%s | %s',{test_pairs={'non-same-length','ambiguous','multichar'}}}`
        + Note that this will also test `multichar` `non-same-length` `ambiguous` pairs
        + Also not the example, in reality there would be one `test_all=true`
+ Add an argument for a test to specify which option the test tests (doesn't need to set for all tests, only once per option) and if an option is found which has no corresponding test then WARN or ERROR
+ test priority (for all profiles including map and raw)
+ create a test for each bug report on github
## TODO (to sort)
+ allow using multiple of the same extensions: for example to create a filter cond and a non filter cond
    + and somehow make it so that pairs and mappings can have different configs for the different extensions
    + Idea of implement: use id
+ When detecting a tsnode, check if the beginning and end are pair and then declude pair from node range
    + or solve the `{""}` where {} is node and filter=string problem
    + What about pairs=<,>;<<,> and <{<>} where {} is node
+ Make it easy to disable creating keymaps with something like `{'(',')',hook={method='none'}}`
    + also `{'(',')',hook={method='autocmd'}}` for autocmd
    + and for mappings `{map={'<bs>',hook={method='autocmd'}}}`
    + OR SOMETHING SIMILAR, NEEDS READJUSTING
+ make a user defined hook: it only activated on user input (instead of needing to create complicated mappings)
+ for extensions like fly, have the filter be at the position where the cursor would be before pair after jump (`{([|])}` > `}` > `{([])|}`)
    + how to do it?
    + have the extensios run before the filter if necessary... (option to do that) (but not for surround extension...)
+ windwp/nvim-ts-autotag integration instead of reimplementing the wheel
+ Be able to disable isolating surtain injected treesitter langs
    + https://github.com/altermo/ultimate-autopair.nvim/issues/69#event-11328741848
    + make sure that `<!--|-->` > `<space>` > `<!-- | -->` (with pair `<!--`,`-->` and filetype=`html` (not markdown)) works
+ config to enable/disable smart pair finding
+ treesitter fastwarp (implement this!)
+ disable an extension for a specific pair/make extensions have their own filters
+ disable an extension/filter for if in cmdline or not
+ make it so that; pairs: `<<`,`>>`,`<<<`,`>>>`; start: `<<|>>`; input: `<`; result `<<<|>>>`
    + basically make it so that if any number of characters match the end pair then don't insert those (not just one char)
+ ignore specific injected langs (like markdown_inline) (+ user config to configure this (per filter?))
+ Add reference to https://github.com/gpanders/nvim-parinfer
+ Hop style fastwarp (aka each possible pos gets a key, and one to go to next line (or a few lines down if jumping over pair (or tsnode)))
+ New map: delete: when press del, delete the backwards pair (and forwards pair of option set)
    + This is useful when you type `<!--` and don't want `-->`, and with this, you only need to hit del once, instead of three times.
+ Make mapping config also work the same way as extensio config (from the outside)
    + For example `{bs_map='<bs>',{'[',']'},{'(',')',bs_map='<C-h>'}}` would turn into `{{'[','],'bs_map='<bs>'},{'(',')',bs_map='<C-h>'}}`
        + In reality this doesn't happen, but instead `{bs_map={'<bs>','<C-h>'}}` and then the backspace lua script does the rest
+ New option smart_less_delete: if there's a subpair in the pair then delete to the subpair: example: pairs: `()` and `()()` and `()|()` > `bs` > `(|)`. Useful for markdown `**|**` > `bs` > `*|*` when pairs `*,*` and `**,**` are defined.
+ A command which opens upp a gui with allows to quickly and dynamically generate a filter for a range/positions.
+ How should the main gui be?
+ IMPORTANT: test if the tests pass(/are skipped) without any parsers installed
+ A global start_pair/end_pair configuration (for example disableing all end_pair backspace)
+ make some filters only run on insert
+ Implement https://github.com/altermo/ultimate-autopair.nvim/issues/80
+ `get_prev_action` gets previous action, if the user does anything then the previous action becomes `nil`
+ for when generating configuration docs, generate a note that states that the default values only apply to whaytever keys they apply to, for example filter alpha default values will only apply to `filter.alpha`.
+ add information to contribiute.md about how to add an option
    + Specifically how to add an option to the config specification.
+ To the Q&A add info about how to create fallbacks, aka how to use the map profile to create a keymap with less priority
+ Test whether the config spec errors when invalid configuration is used
+ add suggestions to error messages (like: `for more info, look ':help ultimate-autopair.*'`)
    + For example if you try to create a end-pair which first character is any alpha then error about that that is not allowed, suggest to change the hook to something else, and also show where in the help file to search for more info
+ be able to separately set the pair and the extra stuff
    + for example you wan't to create a pair `{`,`};`, and only if there are no matching `{` or `}` then you need to have separate match and pair (see https://github.com/altermo/ultimate-autopair.nvim/issues/81)
+ an option for fallback for specific keys (rather than requiring creating a new map profile with the fallbacks)
+ an option to fallback to previous overridden keymappings (a global option)
+ make it so that objects need to return a `do_abbr` to do abbreviations
+ rather than have the open_pair functions be in the open, make it so that the object.info of pairs has such an function option so that it becomes easier to change per pair
+ in hook keymaps, add info about previous keymap to table containing the hooks modules (e.g. allow private fields for hooks in global hook table)
+ in `change` option, check that merge=false works
+ make sure that pairing works in normal mode (e.g. TEST it)
+ make sure that pairing works in terminal mode (e.g. TEST it)
+ create a hook type `before_alpha` and another one called `before_char` (or be able to add an option to `before_char` to limit it to alpha characters)
+ what to do about `cond` filter
    + for now make it PRIVATE (e.g. add an underline to the name (e.g. `_cond`))
    + what to do about the utility functions? (where to put them)
+ make it so that you can do `insert`/`start_pair`/`end_pair` at the root level of the config (which modifies all pairs, unless specified otherwise)
+ a everywhere option `inherit` which works similarly to `merge` but relates to inheriting configuration from the parent table (like pair inheriting the extension configuration)
+ make it so that `false` means that this options is not set (when merging) and should be treted as `nil` if the config is not a boolean (like disabling specific extensions and such)
    + problem: what to do when the config is a boolean and `nil` is different from `true` and `false`?
        + Make a new option `"nil"` (string nil) which is valid for boolean options and set the value to nil
+ A global option to:
    + disable abbreviations
    + make mappings fallback to previously set mappings
        + also test
        + or if it is a table then use that
    + disable caching
+ How to implement line wise caching? (It should be global somehow)
+ In caching, store the count for every line (which means needing to recalculate on the current line if the cursor is not at the beginig or end)
    + Or are there better sulutions?
+ somehow check that length of pair is not used for moving (as it may contain utf8 characters)
+ add `(:h …)` to the major features in the README
+ mark specific config options as can be runtime evaluated and the add a support function which using the config_spec figures out which of those the functions are and smartly evaluates them (when they are indexed) rather than needing to call a function on such an option !important
    + example, instead of `putils.get_opt(conf.foo,...)` it would be `local c=confspec.dyneval_conf(conf,'backspace_conf',o)` (note the `o` argument, which should always be set (whether to `ua.info` or `ua.filter`) and you could add additional data args with `c.__args={...}` (note that `c` would be metatabled so setting a new value on `c` would not change the original conf) and axes any option using `c.foo`
+ each pair is actually four pairs:
    + the action: a keymap which activates the pair logic (typically the last of start pair and first of end pair) (this can be set to multimap keymaps like `<Plug>close_pair`)
    + the detection: the match which is used for detecting pairs before and after the cursor (this can be a lua pattern, MAYBE: can also be a function)
    + the matcher: used for open/closed pair matching (may inherit from the detection if the detection is a lua pattern, can also be function to transform the detection) (MAYBE: can also be a function)
    + The transformer: when using a pattern, and the pattern match a start pair, then the transform will create the associated end pair, and wise versa (maybe: allow string, or somehow make it auto generating (e.g. `%[(=*)%[` + `%](=*)%]` + `[=[` > `]=]`))
    + Exampe of use:
        + lua multiline string: key: `[`,`]`, detect: `%[=-%[` `%]=-%]`, pattern: fallback, transform: `gsub("[","]")` `gsub("]","[")`
+ dynamically require files (using some metatable __index function)
    + IMPORTANT: profile whether this is actually necessary
+ on checkhealth, validate the user configuration (on maximum validation option) (with warnings for some the things that would be errors on warnerr=true (but if there's a warning don't early exit, unlike error))
+ Use this standard to write documentation https://diataxis.fr/
+ if a zero movement (e.g. `<cmd>call setcursor(cursor())\r`) breaks dot: don't create movement command if position is the same
+ when testhing, make it so that the tests are run again but all the pairs are utf8 (non autoconverted) pairs
+ special error function for validation, so that it is not required to pcall the validation function to get the error message
+ in checkhealth, check that the integratied plugins have the correct functions and that they work
+ write in README about when to use `:checkhealth` and other important things for when debugging
+ MAYBE: mark whether a config is optional or necessary (maybe)
+ how to handle the `check_box_ft` option? (e.g. some checkboxes have `[]` while others have `()`, and it also depends on filetype, so make it all configurable, but how)
+ in checkhealth, check whether any keymappings were overwritten (and fallback is not set)
+ ask users to run `:checkhealth` before bug report
+ read through the README before release to make sure it is correct
+ categorize the different tasks in the todo list (also collect from other places (e.g. random todo files in the repo))
+ test that fastwarp `( ")" )foo` > `( ")" foo)` actually works and isn't broken
+ implement a way to add multiple mappings the same way one can add multiple filters
+ implement a way to add multiple extensions the same way one can add multiple filters
+ implement a way to add multiple \* the same way one can add multiple filters
+ in the main init.lua function: have a function for:
    + validating the config
    + merging the config with the default one
    + anything else?
+ be able to set the map_mode in the pair/map config !IMPORTANT
+ when creating multiple mappings/other, be able to inherit(/merge) from the main mapping/other
    + make it a config option
+ check that the validator works by passing in a config with a wrong option (check all possible errors)
+ a way to enable/disable/toggle the whole plugin (and a isenabled function)
+ sorting, for both mem and callbacks in hook.callbacks
+ other types of mappings
    + make it possible to activate mappings without an expr mapping using `nvim_feedkeys`
        + maybe make it default behaviour?
    + make mappings use `InsertCharPre` (and `CmdlineCharPre`)
+ make a hook type that is defined by the object itself (e.g. setup and deletion)
+ Easy documented hook api
    + Like `hook.send_key('(')` > `hook._run('(',mode=utils.mode())`
+ Function based extension enable `{enable=fun()}`
    + For everything, including filters, extensions, pairs, mappings, ...
+ Hook map config
    + For everything, including pairs and mappings.
+ make the boolean|nil option accept `"default"` as a replacement for nil
+ FILTER:
    + have a filter option to whether do use the filter as a filter
    + have a run option to whether do use the filter when run is called
        + both options for pair specific conf
+ ext.tsnode:
    + Instead: in tsnode filter, have a way to check the node before and after a character is fake inserted
    + An option to quickly define groups of nodes, (like `string` or `comment`)
    + A way to define a node as extended (`[//$]`) or contained (`[""]$`)
        + And make it filetype specific
+ Make after-insert a pair option: instead of checking and fake inserting in the filter, do it in the pair filter caller function
+ remember to sort
+ remake extensions into extensions for action type extensions and filters for filtering type extensions
    + make separate config (maybe?)
    + makes it easy to chose what filters apply and if they work only on insert or global (or only noninsert)
+ be able to easily disable all the treesitter features
+ maybe? move the confsys to root instead of being in pair-profile (for easier usage outside of the plugin)
    + or do function bindings in `init.lua`
+ make `find_all_node_types` do caching
+ make `find_all_node_types` do range(row) specific searching
    + and make sure that it is used (e.g. look upp all the places `find_all_node_types` is used)
+ option to make a tsnode range in range inclusive or not
+ config validation:
    + if ingoing is nil then dont validate (except for when higher level validation set, (see below))
    + if ingoing not nil then validate that instead of validating after the merge
        + except when there's a higher level validation (e.g. on `:checkhealth`) where the validation is done both before and after the merge
+ make multiline a runtime option
+ make a way to have a enable option for filters and it being a runtime option (e.g. you can make it a function)
+ `ua.instance` should have a _cache field
+ in `checkhealth`: check that all inherited specs and their keys have a corresponding value in the conf_spec
+ should any filetype_array option be not_table (because that could lead to less confusion)
    + should all string_array option be not_table (because that could lead to less confusion)
+ in the pair (and start_pair/end_pair) config, have an `insert` key which sets the insert filters and other stuff
    + do we need this, because most things can't be set differently between start and end pair?
        + and there are some things which are ambiguous (like `backspace`)
+ for a pair, have a never_act field which when passed an `ua.source`, will tell if it may activate or if it may never activate, useful for when implementing buffer local keymap creating
    + for example, if the filetype is lua, and pair filetype is markdown, then it will never activate, but if the filetype is markdown, and pair filetype is lua, then it may activate
        + in this instance, testing if markdown can contain lua injected language and vice versa would be the condition on whether the pair may act
    + maybe implement this for other objects as well
+ a global option to use buffer local keymaps instead of global ones
+ profile and optimize the filters (and other code which may get run 100+ times)
    + see https://chrisfls.github.io/luajit-wiki/Numerical-Computing-Performance-Guide/
+ move `_lib/filter.lua` to somewhere else (e.g. better name for usage)
+ disable `''` in rust
+ an option to enable commentstring to pair (and have it be shown in the readme)
+ how does `{"a' |","'","a' '|'",{c={filter={alpha={filter=true}}}}},` and `{"a' |","'","a' '|",{c={filter={alpha={filter=false}}}}},` pass?
+ `py_fstr` and `lua_nstr` is a pair local option, so it is confusing to the user when they want to change it globally but can't, so make it a global option
    + also test that `py_fstr=false` and `lua_nstr=false` works
+ implement isolating injected tree languages
+ add a timeit.lua script to test the performance
+ make caching be configurable
+ pre-cache: first calculate which pairs are most used in the file (in the first 100 lines using `string.find`), and then every ~100ms, run the open_pair algorithm on it and cache the results (so that when pair is inserted, the cache is already half full, thus increasing pair insertion speed)
+ test that caching works
+ make treesitter based cache invalidation be active for when filters tsnode or filetype are active
+ about caching, what about filter tsnode being different depending on starting position? (**IMPORTANT**)
+ a global/config-local option to manually set cache clear options (default to `{textchange=true}`) for numbered(anonymous) filters
+ filter option for specific map
+ what about a comment in comment or string in string or injected lang in injected lang? Should they not be isolated from eachother?
+ be able to simply disable a pair (using `{change={{'(',')',enable=false}}}` or something similar)
+ tsnode filter problem, if `insert after` is set and an end_pair is inputted, then what to do (because logically it should not insert another end_pair to parse, but instead use the original end_pair range)?
+ make fastwarp and surround use the same code for where to go, but surround only uses some of it (though why not have an optipon to use all of it)
+ an option to use all the nodes for a particular language (or just all the nodes for all the languages)
+ make inheritance (for multiple mappings/filters) work like this:
    + inherit the main filter/mapping, unless the main filter/mapping is disabled, then don't inherit from it
    + add to *documentation* about you needing to disable main filter/mapping to disable inheritance for non-main filters/mappings
+ filter for tsnodes is still a bit slow:
    + maybe: set whether a specific row has a node or not and cache it (using the builtin row invalidation caching system)
+ what about the mappings needing to be string instead of function because vim (not neovim) doesn't allow functions
+ make sure that something like https://github.com/altermo/ultimate-autopair.nvim/issues/92 doesn't happen again
+ make sure than everything (extensions, mappings, pairs, filters) can be disabled with `enable=false` !important
+ don't autopair `"` if before the cursor is only space/empty in line in vim filetype
    + or temp insert `""` and see if it is string or comment
+ don't autopair `"` if after `@` in vim filetype
+ MAYBE? make things like fastwarp not-undo (e.g. `Ifoo<esc>I(<A-e>foo<esc>u` > `foo` and not `(foo)`)
+ MAYBE? `()a|` > `(a|)` (e.g. remove the closing parentheses if a new one is inserted later on)
+ fastwarp: be able to configure which places to stop (intend of only having two options: normal and faster)
