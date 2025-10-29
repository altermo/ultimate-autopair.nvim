local filterlib=require'ultimate-autopair.filter'
local open_pair=require'ultimate-autopair.open_pair'
local utils=require'ultimate-autopair.utils'
local map_utils=require'ultimate-autopair.map.utils'
local M={}
---@param pair ua.iconfig.pair
---@param mconf ua.iconfig.backspace.root
---@param conf_idx string
---@param con_ ua.context
---@return ua.actions?
local function run_start_pair(pair,mconf,conf_idx,con_)
    local tbl=map_utils.start_pair_type_mapping(pair,mconf,conf_idx,con_,'backspace')
    if not tbl then return end

    local con,start_pair,end_pair,conf,testfns=unpack(tbl)

    if vim.startswith(utils.line_after_range(con,con.cursor_range),end_pair) then
        return {{'delete',start_pair,end_pair}}
    end
    if not conf.overjump then
        return
    elseif conf.overjump=='nonambiguous' and start_pair==end_pair then
        return
    end

    local row,col
    if start_pair==end_pair then
        row,col=open_pair.open_ambiguous_pairs(con.cursor_range,start_pair,con,testfns,true)
    else
        row,col=open_pair.count_start_pair(con.cursor_range,start_pair,end_pair,con,testfns,true)
    end
    if row and col then
        return {{'pos',row,col},{'delete',nil,end_pair},{'orig'},{'delete',start_pair,nil}}
    end
end
---@param mconf ua.iconfig.backspace.root
---@param pairs_ ua.iconfig.pair[]
---@param conf_idx string
---@param con ua.context
---@return ua.actions?
function M.run(mconf,pairs_,conf_idx,con)

    con=utils.con_set_treesitter_enabled(con,mconf.treesitter_enabled)

    for _,pair in ipairs(pairs_) do
        local ret=run_start_pair(pair,mconf,conf_idx,con)
        if ret then
            return ret
        end
    end
end
return M
