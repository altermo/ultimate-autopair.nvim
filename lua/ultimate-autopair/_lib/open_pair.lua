local M={}
---@param o ua.info
---@param gotostart? boolean|"both"
---@param initial_count number?
---@param return_pos boolean?
---@return number?
---@return number?
function M.count_start_pair(o,gotostart,initial_count,return_pos)
    --TODO(fix): if gotostart=='both' and cursor in pair then dont count pair
    local info=(o.m --[[@as ua.prof.def.pair]]).info
    local start_pair=info.start_pair
    local end_pair=info.end_pair
    local multiline=info.multiline
    local start_pair_filter=function (row,col)
        local no=setmetatable({row=row,col=col+#start_pair-1},{__index=o})
        return info._filter.start_pair_filter(no)
    end
    local end_pair_filter=function (row,col)
        local no=setmetatable({row=row,col=col+#end_pair-1},{__index=o})
        return info._filter.end_pair_filter(no)
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
        local real_col
        local rline=line:reverse()
        local next_start_pair=rline:find(start_pair,1,true)
        local next_end_pair=rline:find(end_pair,1,true)
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
    end
    return (not return_pos) and count or nil
end
---@param o ua.info
---@param gotoend? boolean|"both"
---@param initial_count number?
---@param return_pos boolean?
---@return number?
---@return number?
function M.count_end_pair(o,gotoend,initial_count,return_pos)
    --TODO(fix): if gotostart=='both' and cursor in pair then dont count pair
    local info=(o.m --[[@as ua.prof.def.pair]]).info
    local start_pair=info.start_pair
    local end_pair=info.end_pair
    local multiline=info.multiline
    local start_pair_filter=function (row,col)
        local no=setmetatable({row=row,col=col+#start_pair-1},{__index=o})
        return info._filter.start_pair_filter(no)
    end
    local end_pair_filter=function (row,col)
        local no=setmetatable({row=row,col=col+#end_pair-1},{__index=o})
        return info._filter.end_pair_filter(no)
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
        local real_col
        local next_start_pair=line:find(start_pair,1,true)
        local next_end_pair=line:find(end_pair,1,true)
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
    end
    return (not return_pos) and count or nil
end

---@param o ua.info
---@param gotoend? boolean|"both"
---@param initial_count number?
---@param return_pos boolean?
---@return number?
---@return number?
function M.count_ambiguous_pair(o,gotoend,initial_count,return_pos)
    --TODO(fix): if gotostart=='both' and cursor in pair then dont count pair
    local info=(o.m --[[@as ua.prof.def.pair]]).info
    assert(info.start_pair==info.end_pair)
    local pair=info.start_pair
    local multiline=info.multiline
    local start_pair_filter=function (row,col)
        local no=setmetatable({row=row,col=col+#pair-1},{__index=o})
        return info._filter.start_pair_filter(no)
    end
    local end_pair_filter=function (row,col)
        local no=setmetatable({row=row,col=col+#pair-1},{__index=o})
        return info._filter.end_pair_filter(no)
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
        local pos=line:find(pair,1,true)
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
    end
    if not return_pos and count%2==0 then return end
    return index,rowindex
end
return M
