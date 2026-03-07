---@meta

---@alias ua.mode 'i'|'c'|'t'|'v'|'o'|'s'|'n'

---@alias TODO unknown

---@class ua.str

--- srow and erow are 1-indexed
---@alias ua.source.iter_line fun(srow:number,erow:number):fun():number,string

---@class ua.context
---@field iter_lines ua.source.iter_line
---@field cursor_range Range4

---@class ua.config: TODO
---@class ua.iconfig: TODO
---@class ua.actions: TODO

---@alias ua.filter_fn<T> fun(con:ua.context,range:Range4,conf:T):boolean
---@class ua.filter<T>
---@field [1] ua.ifilter<T>
---@field [2] T

---@alias ua.exclude_testfn fun(row:number,col:number):boolean
---@alias ua.exclude_testfns [ua.exclude_testfn,ua.exclude_testfn]
