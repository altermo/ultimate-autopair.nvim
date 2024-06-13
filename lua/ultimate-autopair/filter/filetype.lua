local M={}
local utils=require'ultimate-autopair.utils'
---@param o ua.filter
---@return boolean?
function M.call(o)
    local conf=o.conf
    local ft
    if o.conf.detect_after then
        local parser=utils._HACK_parser_get_after_insert(o,o.conf.detect_after)
        ft=utils.get_filetype(o,{parser=parser,tree=conf.tree})
    else
        ft=utils.get_filetype(o,{tree=conf.tree})
    end
    if conf.ft and not vim.list_contains(conf.ft,ft) then
    elseif conf.nft and vim.list_contains(conf.nft,ft) then
    else return true end
end
M.conf={
    ft='string[]',
    nft='string[]',
}
M.clear_cache={
    'textchange',
    'opt:filetype',
}
return M
