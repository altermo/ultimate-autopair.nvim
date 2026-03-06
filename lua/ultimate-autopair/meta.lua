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

---@alias ua.ifilter.iter_pos_fn<T> fun(con:ua.context,range:Range4,conf:T):boolean
---@alias ua.ifilter.once_fn<T> fun(con:ua.context,conf:T):boolean
---@class ua.ifilter<T>
---@field iter_pos ua.ifilter.iter_pos_fn<T>?
---@field once ua.ifilter.once_fn<T>?
---@class ua.filter
---@field [1] ua.ifilter<any?>
---@field [2] any

---@alias ua.exclude_testfn fun(row:number,col:number):boolean
---@alias ua.exclude_testfns [ua.exclude_testfn,ua.exclude_testfn]
