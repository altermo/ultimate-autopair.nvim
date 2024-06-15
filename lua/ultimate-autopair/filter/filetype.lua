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
    if conf.ft and not utils.in_list(conf.ft,ft) then
    elseif conf.nft and utils.in_list(conf.nft,ft) then
    else return true end
end
M.clear_cache={
    'textchange',
    'treechange',
    'opt:filetype',
}
return M
