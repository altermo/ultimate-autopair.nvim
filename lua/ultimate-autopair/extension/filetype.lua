---I
local M={}
local utils=require'ultimate-autopair.utils'
---@param m prof.def.module
---@param ext prof.def.ext
function M.call(m,ext)
    local conf=ext.conf
    local notree=not conf.tree
    local filter=m.filter
    m.filter=function (o)
        local ft=utils.getsmartft(o,notree)
        if utils.incmd() then return filter(o) end
        if conf.ft and not vim.tbl_contains(conf.ft,ft) then
        elseif conf.nft and vim.tbl_contains(conf.nft,ft) then
        elseif m.conf.ft and not vim.tbl_contains(m.conf.ft,ft) then
        elseif m.conf.nft and vim.tbl_contains(m.conf.nft,ft) then
        else return filter(o) end
    end
end
return M
