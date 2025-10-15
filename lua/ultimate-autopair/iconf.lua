---@meta

---@alias ua.iconfig.use_filetype_getopt table<string|true,boolean|fun(ft:string,opt:string):any>

---@class ua.iconfig.hook
---@field [1] string
---@field priority number
---@field mode ua.mode

---@class ua.iconfig.single_pair
---@field hooks ua.iconfig.hook[]
---@field pair string|ua.dynamic_pair_fn
---@field multiline boolean?
---@field filter ua.iconfig.filters.1
---@field backspace table<any,ua.iconfig.backspace>?
---@field space table<any,ua.iconfig.space>?
---@field newline table<any,ua.iconfig.newline>?
---@field treesitter boolean?

---@class ua.iconfig.pair
---@field start_pair ua.iconfig.single_pair
---@field end_pair ua.iconfig.single_pair

---@class ua.iconfig.filters
---@field [number] ua.config.filter
---@class ua.iconfig.filters.1: ua.iconfig.filters
---@field inherited ua.iconfig.filters
---@class ua.iconfig.filters.2: ua.iconfig.filters.1
---@field inherited_root ua.iconfig.filters

---@class ua.iconfig.map: ua.config.base_map
---@field filter ua.iconfig.filters.2
---@field treesitter boolean?

---@class ua.iconfig.backspace: ua.iconfig.map, ua.config.backspace.opt
---@class ua.iconfig.newline: ua.iconfig.map, ua.config.newline.opt
---@class ua.iconfig.space: ua.iconfig.map, ua.config.space.opt

---@class ua.iconfig.map.root
---@field hooks ua.iconfig.hook[]
---@field filter ua.iconfig.filters.1

---@class ua.iconfig.backspace.root: ua.iconfig.map.root, ua.config.backspace.opt
---@class ua.iconfig.newline.root: ua.iconfig.map.root, ua.config.newline.opt
---@class ua.iconfig.space.root: ua.iconfig.map.root, ua.config.space.opt

---@class ua.iconfig
---@field pairs ua.iconfig.pair[]
---@field use_filetype_getopt ua.iconfig.use_filetype_getopt
---@field treesitter_async boolean
---@field treesitter boolean
---@field backspace table<any,ua.iconfig.backspace.root>
---@field space table<any,ua.iconfig.space.root>
---@field newline table<any,ua.iconfig.newline.root>
---@field perf ua.config.perf
---@field fallback ua.config.fallback
