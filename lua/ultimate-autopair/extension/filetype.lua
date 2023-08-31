---I
---@class ext.filetype.conf:prof.def.ext.conf
---@field ft? string[]|fun(...:prof.def.optfn):string[]?
---@field nft? string[]|fun(...:prof.def.optfn):string[]?
---@field tree? boolean|fun(...:prof.def.optfn):boolean?
---@class ext.filetype.pconf
---@field ft? string[]|fun(...:prof.def.optfn):string[]?
---@field nft? string[]|fun(...:prof.def.optfn):string[]?

local M={}
local utils=require'ultimate-autopair.utils'
local default=require'ultimate-autopair.profile.default.utils'
---@param m prof.def.module
---@param ext prof.def.ext
---@param o core.o
---@param incheck? boolean
---@return boolean?
function M.filter(m,ext,o,incheck)
    local conf=ext.conf
    ---@cast conf ext.filetype.conf
    ---@type ext.filetype.pconf
    local pconf=m.conf
    local notree=not default.orof(conf.tree,o,m,incheck)
    local ft=utils.getsmartft(o,notree)
    local cft=default.orof(conf.ft,o,m,incheck)
    local pcft=default.orof(pconf.ft,o,m,incheck)
    local cnft=default.orof(conf.nft,o,m,incheck)
    local pcnft=default.orof(pconf.nft,o,m,incheck)
    if cft and not vim.tbl_contains(cft,ft) then
    elseif cnft and vim.tbl_contains(cnft,ft) then
    elseif pcft and not vim.tbl_contains(pcft,ft) then
    elseif pcnft and vim.tbl_contains(pcnft,ft) then
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
        if M.filter(m,ext,o,true) then
            return check(o)
        end
    end
end
return M
