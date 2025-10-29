local filterlib=require'ultimate-autopair.filter'
local utils=require'ultimate-autopair.utils'
local open_pair=require'ultimate-autopair.open_pair'

local M={}
---@generic T: ua.iconfig.map.root
---@param pair ua.iconfig.pair
---@param mconf T
---@param conf_idx string
---@param con ua.context
---@param map_idx string
---@return [ua.context,string,string,T,table]?
function M.start_pair_type_mapping(pair,mconf,conf_idx,con,map_idx)
    local conf=(pair.start_pair[map_idx] or {})[conf_idx] or mconf --[[@as ua.iconfig.map]]
    if conf.enable==false then
        return
    end

    if not filterlib.run_once_filters(conf.filter,con) then
        return
    end
    if not filterlib.run_pos_filters(conf.filter,con,con.cursor_range) then
        return
    end

    local start_pair=pair.start_pair.pair
    assert(type(start_pair)=='string')
    local end_pair=pair.end_pair.pair
    assert(type(end_pair)=='string')

    if not pair.start_pair.multiline then
        con=utils.context_to_singleline(con)
    end

    if not vim.endswith(utils.line_before_range(con,con.cursor_range),start_pair) then
        return
    end

    con=utils.con_set_treesitter_enabled(con,pair.start_pair.treesitter)
    con=utils.con_set_treesitter_enabled(con,conf.treesitter)

    if not filterlib.run_once_filters(pair.start_pair.filter,con) then
        return
    end
    filterlib.run_once_filters_no_ret(pair.end_pair.filter,con)

    local start_pair_range={con.cursor_range[1],con.cursor_range[2]-#start_pair,
        con.cursor_range[1],con.cursor_range[2]}
    if not filterlib.run_pos_filters(pair.start_pair.filter,con,start_pair_range) then
        return
    end

    local end_pair_range={con.cursor_range[3],con.cursor_range[4],
        con.cursor_range[3],con.cursor_range[4]+#end_pair}
    if not filterlib.run_pos_filters(pair.end_pair.filter,con,end_pair_range) then
        return
    end

    local testfns=filterlib.pair_to_filters(con,pair.start_pair,pair.end_pair,start_pair,end_pair)

    if start_pair==end_pair then
        if open_pair.open_ambiguous_pairs(con.cursor_range,start_pair,con,testfns,'both') then
            return
        end
    else
        local count1=open_pair.count_start_pair(con.cursor_range,start_pair,end_pair,con,testfns)
        local count2=open_pair.count_end_pair(con.cursor_range,start_pair,end_pair,con,testfns)
        if count1>count2 then return end
    end

    return {con,start_pair,end_pair,conf,testfns}
end
return M
