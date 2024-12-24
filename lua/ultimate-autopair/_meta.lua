---@meta

---@class ua.config
---@field [any] any

---@class ua.iconfig._pair
---@field _start_pair ua.iconfig.pair
---@field _end_pair ua.iconfig.pair

---@class ua.iconfig.pair
---@field _match string|function
---@field _hooks table[]
---@field priority number
---@field fallback string?
---@field multiline false|(true|nil)

---@class ua.config.pair
---@field [any] any

---@class ua.source
---@field bufnr number? --if nil then source is cmdline
---@field iter_lines fun(srow:number,erow:number):fun():number,string

---@class ua.context.pos
---@field source ua.source
---@field line_pre string
---@field line_pos string
---@field row number
---@field col number

---@class ua.actions
---@field [number] ua.action|string

---@class ua.action

---Row are range-indexed (e.g. 0-indexed, same as treesitter ranges)
---@class ua.ranges
---@field [number] nil|true|ua.subranges
---List(1-indexed) where odd-indexes are start-col and even-indexes are end-col
---This list should be sorted, as in `next(subrange)<=next(next(subrange))`
---If a start-col and the following end-col is the same, then they should be merged
---Cols are range-indexed (e.g. 0-indexed, same as treesitter ranges)
---If col is negative, then the actual col is `-1-col` and is inclusive
---@alias ua.subranges number[]
