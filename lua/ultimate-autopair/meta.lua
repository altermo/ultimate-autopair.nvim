---@meta

---@alias ua.mode 'i'|'c'|'t'|'v'|'o'|'s'|'n'

---TODO {{
---@alias ua.dynamic_pair_fn fun(...):string?,string?

--- }}

--- srow and erow are 1-indexed
---@alias ua.source.iter_line fun(srow:number,erow:number):fun():number,string

---@class ua.context
---@field bufnr number? --if nil then source is cmdline
---@field root_filetype string
---- TODO: what to do with this?, can't replace with `string[]` because memory
---@field iter_lines ua.source.iter_line
---@field _parser? vim.treesitter.LanguageTree|false
---@field cursor_range Range4
---@field iconf ua.iconfig
---@field treesitter_enabled boolean

---@class ua.actions
---@field [number] ua.action|string

---@class ua.action
---@field [1] 'home'|'end'|'delete'|'l'|'h'|'k'|'j'|'newline'
---@field [number] any

---@class ua.config.filter.spec: ua.config.filter
---@field _name ua.config.filters.name
---@field _conf ua.config.filter.base.1
---@field filter ua.config.filters.root
---@field filter_or ua.config.filters.root
---@field singlechar boolean
