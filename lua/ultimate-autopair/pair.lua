local utils=require'ultimate-autopair.utils'
local open_pair=require'ultimate-autopair.open_pair'
local filterlib=require'ultimate-autopair.filter'
local M={}

---@param bconf ua.iconfig.pair
---@param con ua.context
---@return ua.actions?
function M.run_start(bconf,con)
    local end_pair
    local conf=bconf.start_pair
    local start_pair=conf.pair
    if type(start_pair)=='function' then
        local pairs_={start_pair()}
        if not pairs_[1] then
            return
        end
        start_pair,end_pair=unpack(pairs_) --[[@as string]]
        assert(end_pair,'TODO: error about how tow pairs are needed to be returned')
        assert(type(start_pair)=='string','TODO: errmsg')
        assert(type(end_pair)=='string','TODO: errmsg')
    else
        end_pair=bconf.end_pair.pair --[[@as string]]
        assert(type(end_pair)=='string')
    end
    --TODO: what if the start/end_pair == '' (empty string) (write test for both start and end -pair)
    if not conf.multiline then
        con=utils.context_to_singleline(con)
    end
    if not vim.endswith(utils.line_before_range(con,con.cursor_range),utils.utf8sub(start_pair,1,-2)) then
        return
    end
    if not filterlib.run_once_filters(conf.filter,con) then
        return
    end
    local pair_range={con.cursor_range[1],
        con.cursor_range[2]-(vim.api.nvim_strwidth(start_pair)-1),
        con.cursor_range[3],con.cursor_range[4]}
    if not filterlib.run_pos_filters(conf.filter,con,pair_range) then
        return
    end
    local fn=function () return true end
    local row,col=con.cursor_range[1]+1,con.cursor_range[2]+1
    if start_pair==end_pair then
        if open_pair.open_ambiguous_pairs(row,col,start_pair,con,fn,fn,'both') then
            return
        end
    else
        local count1=open_pair.count_start_pair(row,col,start_pair,end_pair,con,fn,fn)
        local count2=open_pair.count_end_pair(row,col,start_pair,end_pair,con,fn,fn)
        if count1<count2 then return end
    end
    return {
        utils.utf8sub(start_pair,-1),
        end_pair,
        {'h',end_pair},
    }
end
---@param bconf ua.iconfig.pair
---@param con ua.context
---@return ua.actions?
function M.run_end(bconf,con)
    local start_pair
    local conf=bconf.end_pair
    local end_pair=conf.pair
    if type(end_pair)=='function' then
        local pairs_={end_pair()}
        if not pairs_[1] then
            return
        end
        end_pair,start_pair=unpack(pairs_) --[[@as string]]
        assert(start_pair,'TODO: error about how tow pairs are needed to be returned')
        assert(type(end_pair)=='string','TODO: errmsg')
        assert(type(start_pair)=='string','TODO: errmsg')
    else
        start_pair=bconf.start_pair.pair --[[@as string]]
        assert(type(start_pair)=='string')
    end
    if not conf.multiline then
        con=utils.context_to_singleline(con)
    end
    if not vim.startswith(utils.line_after_range(con,con.cursor_range),end_pair) then return end
    local pair_range={con.cursor_range[1],con.cursor_range[2],con.cursor_range[3],
        con.cursor_range[4]+vim.api.nvim_strwidth(start_pair)}
    if not filterlib.run_pos_filters(conf.filter,con,pair_range) then
        return
    end
    local fn=function () return true end
    local row,col=con.cursor_range[1]+1,con.cursor_range[2]+1
    if start_pair==end_pair then
        --if there's an uneven number of ambiguous pairs or if were not in a pair
        local open_pair_before=open_pair.open_ambiguous_pairs(row,col,start_pair,con,fn,fn)
        if not open_pair_before then return end
        local open_pair_after=open_pair.open_ambiguous_pairs(row,col,start_pair,con,fn,fn,true,1)
                if open_pair_after then return end
    else
        local count1=open_pair.count_start_pair(row,col,start_pair,end_pair,con,fn,fn)
        local count2=open_pair.count_end_pair(row,col,start_pair,end_pair,con,fn,fn)
        if count1==0 or count1>count2 then return end
    end
    return {
        {'l',end_pair},
    }
end

return M
