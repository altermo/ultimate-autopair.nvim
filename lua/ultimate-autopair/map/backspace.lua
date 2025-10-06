local filterlib=require'ultimate-autopair.filter'
local open_pair=require'ultimate-autopair.open_pair'
local utils=require'ultimate-autopair.utils'
local M={}
---@param pair ua.iconfig.pair
---@param mconf ua.iconfig.backspace.root
---@param conf_idx string
---@param con ua.context
---@return ua.actions?
local function run_start_pair(pair,mconf,conf_idx,con)
    local conf=(pair.start_pair.backspace or {})[conf_idx] or mconf
    if conf.enable==false then
        return
    end

    --TODO: Okay, maybe we should collect all the filters into one big function

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

    if not filterlib.run_once_filters(pair.start_pair.filter,con) then
        return
    end
    filterlib.run_once_filters(pair.end_pair.filter,con)

    local start_pair_range={con.cursor_range[1],con.cursor_range[2]-#start_pair,
        con.cursor_range[3],con.cursor_range[4]}
    if not filterlib.run_pos_filters(pair.start_pair.filter,con,start_pair_range) then
        return
    end

    local end_pair_range={con.cursor_range[1],con.cursor_range[2],
        con.cursor_range[3],con.cursor_range[4]+#end_pair}
    if not filterlib.run_pos_filters(pair.end_pair.filter,con,end_pair_range) then
        return
    end

    if not vim.endswith(utils.line_before_range(con,con.cursor_range),start_pair) then
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
    for _,pair in ipairs(pairs_) do
        local ret=run_start_pair(pair,mconf,conf_idx,con)
        if ret then
            return ret
        end
    end
end
return M
