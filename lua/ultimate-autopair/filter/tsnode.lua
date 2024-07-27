local utils=require'ultimate-autopair.utils'
local query=require'ultimate-autopair._lib.query'
local M={}
M.id={}
---@param o ua.filter
---@param trange number[]
---@return boolean?
function M.filter(o,trange)
    local range={o.rows-1,o.cols-1,o.rowe-1,o.cole-1}
    if utils.range_in_range(trange,range,true) then
        return true
    end
end
---@param o ua.filter
---@return boolean?
function M.call(o)
    local range={o.rows-1,o.cols-1,o.rowe-1,o.cole-1}
    if o.conf.separate and o.pre_conf then
        if o.pre_conf.a then
            for _,trange in ipairs(o.pre_conf) do
                if utils.range_in_range(trange,range,false) then
                    return false
                end
            end
        else
            if not M.filter(o,o.pre_conf) then return end
        end
    end
    if o.conf.dont then
        local parser
        if o.conf.detect_after then --TODO: only run if needed
            --TODO: modify the range to correctly detect the node, as it should be offset by the inserted character
            parser=utils._HACK_parser_get_after_insert(o,o.conf.detect_after) --TODO: detect if treesitter enabled before this
        else
            parser=o.source.get_parser()
        end
        if not parser then return true end
        if #query.find_all_node_types(parser,o.conf.dont)>0 then
            return false
        end
    end
    return true
end
---@param o ua.filter
---@return any,boolean?
function M.pre_call(o)
    if not o.conf.separate then return end
    local parser
    if o.conf.detect_after then
        --TODO: maybe detect_after should not be used here because many ranges will be wrong
        parser=utils._HACK_parser_get_after_insert(o,o.conf.detect_after) --TODO: detect if treesitter enabled before this
    else
        parser=o.source.get_parser()
    end
    if not parser then return end
    local separate=utils.flatten_config_for_filetype(o.conf.separate,o.source.o.filetype)
    local nodes=query.find_all_node_types(parser,separate)
    local range={o.rows-1,o.cols-1,o.rowe-1,o.cole-1}
    local ranges={a=true}
    for _,node in ipairs(nodes) do
        local trange={node:range()}
        table.insert(ranges,trange)
        if utils.range_in_range(trange,range,false) then
            return trange,true
        end
    end
    return ranges,false
end
M.clear_cache={
    'textchange',
    'treechange',
    'opt:filetype',
}
return M
