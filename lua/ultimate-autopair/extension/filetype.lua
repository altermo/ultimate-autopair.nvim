---I
---@class ext.filetype.conf:prof.def.ext.conf
---@field ft? string[]
---@field nft? string[]
---@field tree? boolean
---@class ext.filetype.pconf
---@field ft? string[]
---@field nft? string[]

local M={}
local utils=require'ultimate-autopair.utils'
---@param m prof.def.module
---@param ext prof.def.ext
---@param o core.o
---@return boolean?
function M.filter(m,ext,o)
    local conf=ext.conf
    ---@cast conf ext.filetype.conf
    ---@type ext.filetype.pconf
    local pconf=m.conf
    local notree=not conf.tree
    local ft=utils.getsmartft(o,notree)
    if conf.ft and not vim.tbl_contains(conf.ft,ft) then
    elseif conf.nft and vim.tbl_contains(conf.nft,ft) then
    elseif pconf.ft and not vim.tbl_contains(pconf.ft,ft) then
    elseif pconf.nft and vim.tbl_contains(pconf.nft,ft) then
    else return true end
end
---@param m prof.def.module
---@param ext prof.def.ext
function M.call(m,ext)
    local filter=m.filter
    m.filter=function(o)
        if M.filter(m,ext,o) then
            return filter(o)
        end
    end
    local check=m.check
    m.check=function(o)
        if M.filter(m,ext,o) then
            return check(o)
        end
    end
end
return M
