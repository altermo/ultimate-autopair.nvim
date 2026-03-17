---@meta

---@alias ua.mode 'i'|'c'|'t'|'v'|'o'|'s'|'n'

---@alias TODO unknown

---@class ua.str

--- srow and erow are 1-indexed
---@alias ua.source.iter_line fun(srow:number,erow:number):fun():integer,string

---@class ua.context
---@field iter_lines ua.source.iter_line
---@field cursor_range Range4
---@field bufnr integer?

---@class ua.config: TODO
---@class ua.iconfig: TODO

---@alias ua.filter_fn<T> fun(con:ua.context,range:Range4,conf:T):boolean
---@class ua.filter<T>
---@field [1] ua.ifilter<T>
---@field [2] T

---@alias ua.excludefn fun(row:integer,col:integer):boolean
