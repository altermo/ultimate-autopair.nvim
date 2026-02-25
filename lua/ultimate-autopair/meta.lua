---@meta

---@alias ua.mode 'i'|'c'|'t'|'v'|'o'|'s'|'n'

---@class ua.str: string

--- srow and erow are 1-indexed
---@alias ua.source.iter_line fun(srow:number,erow:number):fun():number,string

---@class ua.context
---@field iter_lines ua.source.iter_line

---@class ua.config: table
---@class ua.iconfig: table
---@class ua.actions: table
