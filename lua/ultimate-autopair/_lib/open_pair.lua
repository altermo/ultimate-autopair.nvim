local utils=require'ultimate-autopair.utils'
local cachelib=require'ultimate-autopair.cache'
local M={}
local caches_count_star_pair={}
---@param o ua.info
---@param gotostart? boolean|"both"
---@param initial_count number?
---@param return_pos boolean?
---@return number?
---@return number?
function M.count_start_pair(o,gotostart,initial_count,return_pos)
    local cache
    if type(o.source.source)=='number' and not return_pos then
        --TODO: implement caching when return_pos is true
        cache=cachelib.buf_get_cache(o.source.source --[[@as number]],caches_count_star_pair)
    end
    --TODO(fix): if gotostart=='both' and cursor in pair then dont count pair
    local m=o.m --[[@as ua.prof.pair.pair]]
    local start_pair=m.start_pair_old
    local end_pair=m.end_pair_old
    local multiline=m.multiline
    local start_pair_filter=function (row,col)
        local no=setmetatable({row=row,col=col},{__index=o})
        return utils.run_filters(m.start_pair_filter,no,0,-#start_pair)
    end
    local end_pair_filter=function (row,col)
        local no=setmetatable({row=row,col=col},{__index=o})
        return utils.run_filters(m.end_pair_filter,no,0,-#end_pair)
    end

    start_pair=start_pair:reverse()
    end_pair=end_pair:reverse()
    local rev_lines={o.line}
    if multiline then
        rev_lines=vim.fn.reverse(vim.list_slice(o.lines,(not gotostart) and o.row or nil,gotostart==true and o.row or nil))
    end
    local count=initial_count or 0
    if not gotostart then rev_lines[#rev_lines]=rev_lines[#rev_lines]:sub(o.col) end
    if gotostart==true then rev_lines[1]=rev_lines[1]:sub(1,o.col-1) end
    for row,line in ipairs(rev_lines)do
        row=(multiline and gotostart~=true and #o.lines or o.row)+1-row
        if row~=o.row then assert(o.lines[row]==line) end
        if cache and cache[row] and o.row~=row then
            count=count+cache[row]
            goto continue
        end
        local real_col
        local rline=line:reverse()
        local next_start_pair=rline:find(start_pair,1,true)
        local next_end_pair=rline:find(end_pair,1,true)
        local rcount=count
        while true do
            if next_start_pair and ((not next_end_pair) or next_start_pair<next_end_pair) then
                real_col=((not gotostart) and row==o.row and #o.lines[row] or #line)-next_start_pair+1-#start_pair+1
                if start_pair_filter(row,real_col) then count=count-1 end
                next_start_pair=rline:find(start_pair,next_start_pair+#start_pair,true)
            elseif next_end_pair then
                real_col=((not gotostart) and row==o.row and #o.lines[row] or #line)-next_end_pair+1-#end_pair+1
                if end_pair_filter(row,real_col) then count=count+1 end
                next_end_pair=rline:find(end_pair,next_end_pair+#end_pair,true)
            else break end
            if return_pos and count<0 then
                return real_col,row
            elseif count<0 then
                count=0
            end
        end
        if cache then cache[row]=count-rcount end
        ::continue::
    end
    return (not return_pos) and count or nil
end
local caches_count_end_pair={}
---@param o ua.info
---@param gotoend? boolean|"both"
---@param initial_count number?
---@param return_pos boolean?
---@return number?
---@return number?
function M.count_end_pair(o,gotoend,initial_count,return_pos)
    local cache
    if type(o.source.source)=='number' and not return_pos then
        --TODO: implement caching when return_pos is true
        cache=cachelib.buf_get_cache(o.source.source --[[@as number]],caches_count_end_pair)
    end
    --TODO(fix): if gotostart=='both' and cursor in pair then dont count pair
    local m=o.m --[[@as ua.prof.pair.pair]]
    local start_pair=m.start_pair_old
    local end_pair=m.end_pair_old
    local multiline=m.multiline
    local start_pair_filter=function (row,col)
        local no=setmetatable({row=row,col=col},{__index=o})
        return utils.run_filters(m.start_pair_filter,no,0,-#start_pair)
    end
    local end_pair_filter=function (row,col)
        local no=setmetatable({row=row,col=col},{__index=o})
        return utils.run_filters(m.end_pair_filter,no,0,-#end_pair)
    end

    local lines={o.line}
    if multiline then
        lines=vim.list_slice(o.lines,gotoend==true and o.row or nil,(not gotoend) and o.row or nil)
    end
    local count=initial_count or 0
    if not gotoend then lines[#lines]=lines[#lines]:sub(1,o.col-1) end
    if gotoend==true then lines[1]=lines[1]:sub(o.col) end
    for row,line in ipairs(lines) do
        row=((gotoend==true or not multiline) and o.row-1 or 0)+row
        if row~=o.row then assert(o.lines[row]==line) end
        if cache and cache[row] and o.row~=row then
            count=count+cache[row]
            goto continue
        end
        local real_col
        local next_start_pair=line:find(start_pair,1,true)
        local next_end_pair=line:find(end_pair,1,true)
        local rcount=count
        while true do
            if next_start_pair and ((not next_end_pair) or next_start_pair<next_end_pair) then
                real_col=next_start_pair+(gotoend==true and row==o.row and o.col-1 or 0)
                if start_pair_filter(row,real_col) then count=count+1 end
                next_start_pair=line:find(start_pair,next_start_pair+#start_pair,true)
            elseif next_end_pair then
                real_col=next_end_pair+(gotoend==true and row==o.row and o.col-1 or 0)
                if end_pair_filter(row,real_col) then count=count-1 end
                next_end_pair=line:find(end_pair,next_end_pair+#end_pair,true)
            else break end
            if return_pos and count<0 then
                return real_col,row
            elseif count<0 then
                count=0
            end
        end
        if cache then
            cache[row]=count-rcount
        end
        ::continue::
    end
    return (not return_pos) and count or nil
end
local caches_count_ambiguous_pair={}
---@param o ua.info
---@param gotoend? boolean|"both"
---@param initial_count number?
---@param return_pos boolean?
---@return number?
---@return number?
function M.count_ambiguous_pair(o,gotoend,initial_count,return_pos)
    local cache
    if type(o.source.source)=='number' and not return_pos then
        --TODO: implement caching when return_pos is true
        cache=cachelib.buf_get_cache(o.source.source --[[@as number]],caches_count_ambiguous_pair)
    end
    --TODO(fix): if gotostart=='both' and cursor in pair then dont count pair
    local m=o.m --[[@as ua.prof.pair.pair]]
    assert(m.start_pair_old==m.end_pair_old)
    local pair=m.start_pair_old
    local multiline=m.multiline
    local start_pair_filter=function (row,col)
        local no=setmetatable({row=row,col=col},{__index=o})
        return utils.run_filters(m.start_pair_filter,no,0,-#pair)
    end
    local end_pair_filter=function (row,col)
        local no=setmetatable({row=row,col=col},{__index=o})
        return utils.run_filters(m.end_pair_filter,no,0,-#pair)
    end

    local count=initial_count or 0
    local index
    local rowindex
    local lines={o.line}
    if multiline then
        lines=vim.list_slice(o.lines,gotoend==true and o.row or nil,(not gotoend) and o.row or nil)
    end
    if not gotoend then lines[#lines]=lines[#lines]:sub(1,o.col-1) end
    if gotoend==true then lines[1]=lines[1]:sub(o.col) end
    for row,line in ipairs(lines) do
        row=((gotoend==true or not multiline) and o.row-1 or 0)+row
        if row~=o.row then assert(o.lines[row]==line) end
        if cache and cache[row] and o.row~=row then
            count=count+cache[row]
            goto continue
        end
        local pos=line:find(pair,1,true)
        local rcount=count
        while pos do
            local real_col=pos+(gotoend==true and row==o.row and o.col-1 or 0)
            if ((count%2==1 and end_pair_filter(row,real_col)) or
                (count%2==0 and start_pair_filter(row,real_col))) then
                count=count+1
                if not gotoend or not index then
                    index=real_col
                    rowindex=row
                end
            end
            pos=line:find(pair,pos+#pair,true)
        end
        if cache then cache[row]=count-rcount end
        ::continue::
    end
    if not return_pos and count%2==0 then return end
    return index,rowindex
end
return M
