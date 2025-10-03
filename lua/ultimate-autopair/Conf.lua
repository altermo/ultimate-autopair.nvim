---@meta

---Doc format: start with 4 dashes (e.g. `----`), then the description
---Special attributes:
--- `{...}`: the default value in default config

---@alias ua.config.modes ua.mode[]|ua.mode

---@alias ua.config.use_filetype_getopt false|true|ua.iconfig.use_filetype_getopt|fun(ft:string,opt:string):any

---@alias ua.config.filetypes string[]|string
---@alias ua.config.nodes string|{[number]:string,[string]:string|string[]}

---@alias ua.config.nodeclass 'string'|'comment'

---@class ua.config.hook: ua.config.base_hook
---@field [1] string

---@class ua.config.base_hook
---@field mode ua.config.modes?
---@field priority number?

---@class ua.config.base_map
---@field enable boolean?
--- TODO: the filtering should be applied to the pairs which the map runs on (so that filters such as escape make sense to set on map, because otherwise only things like filetype filter would be useful...)
---@field filter ua.config.filters.root_inherit?
--- TODO: how should this(treesitter disabling) work? (wouldn't it make sense to only do it pairwise)
---@field treesitter boolean?
---@class ua.config.base_map.inherit: ua.config.base_map
---- It defaults `filter.inherit_root_filters` to `true`
---@field inherit boolean?
---@field filter ua.config.filters.map_inherit?
---@class ua.config.base_map.root: ua.config.base_map, ua.config.base_hook
---@field map string|(string|ua.config.hook)[]

---@class ua.config.backspace.opt
---@field overjump boolean|'nonambiguous'?
---@field space boolean|'balanced'?
---@field newline boolean|'indent_ignore'?
---@field single_delete boolean?
---@class ua.config.backspace: ua.config.backspace.opt,ua.config.base_map
---@class ua.config.backspace.root: ua.config.backspace, ua.config.base_map.root
---@class ua.config.backspace.inherit: ua.config.backspace, ua.config.base_map.inherit

---@class ua.config.newline.opt
---@class ua.config.newline: ua.config.newline.opt,ua.config.base_map
---@class ua.config.newline.root: ua.config.newline, ua.config.base_map.root
---@class ua.config.newline.inherit: ua.config.newline, ua.config.base_map.inherit

---@class ua.config.space.opt
---@field check_box_ft ua.config.filetypes?
---@class ua.config.space: ua.config.space.opt,ua.config.base_map
---@class ua.config.space.root: ua.config.space, ua.config.base_map.root
---@class ua.config.space.inherit: ua.config.space, ua.config.base_map.inherit

---@class ua.config.fastwarp.opt
---@field type 'normal'|'treesitter'|'fast'?
---@field r_enable boolean?
---- Whether to treat a filter region as if it was a pair {true}
---@field hop_filter_region boolean?
---@class ua.config.fastwarp: ua.config.fastwarp.opt,ua.config.base_map
---@class ua.config.fastwarp.root: ua.config.fastwarp, ua.config.base_map.root
---@field map string|(string|ua.config.hook)[]?
---@field r_mode ua.config.modes?
---@field r_priority number?
---@field r_map string|(string|ua.config.hook)[]?
---@class ua.config.fastwarp.inherit: ua.config.fastwarp, ua.config.base_map.inherit

---@class ua.config.base_pair: ua.config.base_hook
---@field multiline boolean?
---@field filter ua.config.filters.root_inherit?
---@field smart_pairing boolean?
---@class ua.config.single_pair: ua.config.pair_no_12
---@field [1] string|(string|ua.config.hook)[]
---@field [2] string|ua.dynamic_pair_fn?
---@class ua.config.pair_no_12: ua.config.base_pair
---@field backspace ua.config.backspace.inherit|false?
---@field backspace_multi table<any,ua.config.backspace.inherit|false>?
---@field newline ua.config.newline.inherit|false?
---@field newline_multi table<any,ua.config.newline.inherit|false>?
---@field space ua.config.space.inherit|false?
---@field space_multi table<any,ua.config.space.inherit|false>?
---@field fastwarp ua.config.fastwarp.inherit|false?
---@field fastwarp_multi table<any,ua.config.fastwarp.inherit|false>?
---@field treesitter boolean?
--- --TODO:
--- insta_newline (newline when pairing)
--- surround (surround pairs which have besurrounded=true) and besurrounded
---@class ua.config.pair: ua.config.pair_no_12
---@field [1] string|ua.config.single_pair
---@field [2] string|ua.config.single_pair

---@class ua.config.filter.base
---@field enable boolean?
---@class ua.config.filter.base.1
---@field filter ua.config.filters.root?
---- If the filter is filtered, then the filter_or is used
---@field filter_or ua.config.filters.root?
---- (TODO) If set, make the filtering not be done in the pair-iterator
---@field singlechar boolean?

---- @type:once
---@class ua.config.filter.cmdtype: ua.config.filter.base.1
---@field skip (''|':'|'>'|'/'|'?'|'@'|'-'|'=')[]|(''|':'|'>'|'/'|'?'|'@'|'-'|'=')

---- @type:pos
---@class ua.config.filter.escape: ua.config.filter.base.1

---- @type:pos/once
---@class ua.config.filter.alpha: ua.config.filter.base.1
---@field before boolean|string?
---@field after boolean|string?
---@field fstring_smart boolean?
---@field luastr_smart boolean? --TODO
---- Whether to only filter on insert, or everywhere {true}
---@field insert_only boolean? (TODO: replace with singlechar)

---- @type:once/range
---@class ua.config.filter.filetype: ua.config.filter.base.1
---@field ft ua.config.filetypes?
---@field nft ua.config.filetypes?
---- Whether to use treesitter injected langs {true}
---@field treesitter boolean?
---- Whether to separate treesitter injected langs {true}
---@field injectlang_separate boolean?
---- Temp insert one character to detect zero-width filetypes {false}
---@field temp_insert boolean?

---- @type:range
---- TODO: a way to only pair in specific nodes
---@class ua.config.filter.tsnode: ua.config.filter.base.1
---@field query table<string,string>?
---@field nodeclass_filter table<ua.config.nodeclass|true,false|'separate'|'exclude'>?
---@field separate ua.config.nodes?
---@field separate_inclusive ua.config.nodes?
---@field exclude ua.config.nodes?
---@field exclude_inclusive ua.config.nodes?

    ---TODO: instead of pos,range,once we still have pos and once, but range is replaced by a table of functions with the entries, all of the entries are function and optional
    --- once: run once, if returns a table, store as STATE for current pairing
    ---       second values designate if the other entries will run
    ---       this is for example useful for filetype, which if treesitter
    ---       is disabled, needs only to run once, but if treesitter
    ---       is enabled, then the rest will run
    --- prepare: receives arguments: is_ambiguous, is_end, STATE(only if once return state) (or it could just be the current pair...)
    ---       always runs before a loop, used for preparing iterators
    --- pos: runs on pos (actually range, so maybe rename), may not necessary have a prepare run before this (argument which signals that prepare has indeed been run before, e.g. were in a loop, and not just a single pos detection)
    --- row: same as pos, but it applies to rows. Would be useful on range filter to quickly discard unimportant rows
---@class ua.config.filter: ua.config.filter.base.1
---@field once? fun(con:ua.context):boolean?,boolean?
---@field on_iter? fun(con:ua.context,range:Range4,type_:'normal'|'reverse'):nil
---@field pos? fun(con:ua.context,range:Range4,is_iter:boolean):boolean?
----@field row? fun(source:string):boolean? --TODO
---@class ua.config.filter.anonymous: ua.config.filter.base, ua.config.filter

---@alias ua.config.filters.name
---|'filetype'
---|'tsnode'
---|'cmdtype'
---|'escape'
---|'alpha'
---|'other'
---@alias ua.config.filters.names ua.config.filters.name[]|ua.config.filters.name

---@class ua.config.filters.root
---@field enable boolean?
---@field filetype ua.config.filter.filetype|false?
---@field filetype_multi ua.config.filter.filetype[]?
---@field tsnode ua.config.filter.tsnode|false?
---@field tsnode_multi ua.config.filter.tsnode[]?
---@field cmdtype ua.config.filter.cmdtype|false?
---@field cmdtype_multi ua.config.filter.cmdtype[]?
---@field escape ua.config.filter.escape|false?
---@field escape_multi ua.config.filter.escape[]?
---@field alpha ua.config.filter.alpha|false?
---@field alpha_multi ua.config.filter.alpha[]?
---@field [number] ua.config.filter.anonymous
---@class ua.config.filters.root_inherit: ua.config.filters.root
---@field inherit_root_filters ua.config.filters.names|boolean?
---@class ua.config.filters.map_inherit: ua.config.filters.root_inherit
---- If nil, then same as `inherit_root_filters`
---@field inherit_root_map_filters ua.config.filters.names|boolean?

---TODO:  also use some kind of enum for keys which are tested to be correct in checkhealth
---@class ua.config.default
---@field [number] string
---@field exclude boolean?
---@field pair table<string,ua.config.pair_no_12>?

---@class ua.config.base_perf
--- In seconds
---@field timeout number?
---@field byte_limit number?
---@field row_limit number?

---@class ua.config.perf.treesitter: ua.config.base_perf
---@field async ua.config.base_perf --TODO: when limit reached, use async parsing (this should replace the `treesitter_async` option)

---@class ua.config.perf: ua.config.base_perf
---@field treesitter ua.config.perf.treesitter
---@field smart_pairing ua.config.base_perf
---@field multiline ua.config.base_perf

---@class ua.config.fallback.entry
---@field [ua.mode] string|true|fun():string
---@field [true] string|true|fun():string
---@class ua.config.fallback
---@field [true] string|true|ua.config.fallback.entry|fun():string
---@field [string] string|true|ua.config.fallback.entry|fun():string

---@class ua.config
---@field map_mode ua.config.modes?
---@field pair_map_mode ua.config.modes?
---@field priority number?
---@field multiline boolean?
---@field use_filetype_getopt ua.config.use_filetype_getopt?
---@field [number] ua.config.pair
---@field backspace ua.config.backspace.root?
---@field backspace_multi table<any,ua.config.backspace.root>?
---@field newline ua.config.newline.root?
---@field newline_multi table<any,ua.config.newline.root>?
---@field space ua.config.space.root?
---@field space_multi table<any,ua.config.space.root>?
---@field fastwarp ua.config.fastwarp.root?
---@field fastwarp_multi table<any,ua.config.fastwarp.root>?
---@field root_filter ua.config.filters.root?
---- Global treesitter switch
---@field treesitter boolean?
---@field validate number|boolean?
---@field err_format ua.conf.err_format?
---@field default ua.config.default|boolean?
---@field perf ua.config.perf?
---@field smart_pairing boolean?
---@field fallback ua.config.fallback?
---@field treesitter_async boolean?
