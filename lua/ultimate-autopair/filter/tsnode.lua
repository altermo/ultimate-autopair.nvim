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
    local parser
    if o.conf.detect_after then
        --TODO: modify the range to correctly detect the node
        parser=utils._HACK_parser_get_after_insert(o,o.conf.detect_after) --TODO: detect if treesitter enabled before this
    else
        parser=o.source.get_parser()
    end
    if not parser then return true end
    if o.conf.separate and o.lsave then
        local separate=query.get_node_types_from_config(o.conf.separate,utils.get_filetype(o,{parser=parser,tree=true}))
        if o.lsave[M.id]==false then
            local nodes=query.find_all_node_types(parser,separate)
            for _,node in ipairs(nodes) do
                local trange={node:range()}
                if utils.range_in_range(trange,range,false) then
                    return false
                end
            end
        elseif o.lsave[M.id] then
            if not M.filter(o,o.lsave[M.id]) then return end
        else
            local nodes=query.find_all_node_types(parser,separate)
            o.lsave[M.id]=false
            for _,node in ipairs(nodes) do
                local trange={node:range()}
                if utils.range_in_range(trange,range,false) then
                    o.lsave[M.id]=trange
                    break
                end
            end
        end
    end
    if o.conf.dont then
        if #query.find_all_node_types(parser,o.conf.dont)>0 then
            return false
        end
    end
    return true
end
M.clear_cache={
    'textchange',
    'treechange',
}
return M
