local M={}
---@param range Range4
function M.add_range(ranges,range)
    local rows=range[1]
    local rowe=range[3]
    local cols=range[2]
    local cole=range[4]
    if rows~=rowe then
        for row=rows+1,rowe-1 do
            ranges[row]=true
        end
        M.add_range(ranges,{rows,cols,rows,-1})
        M.add_range(ranges,{rowe,0,rowe,cole})
        return
    end
    if ranges[rows]==true then
        return
    end
    if ranges[rows]==nil then
        ranges[rows]={cols,cole}
        return
    end
    error('TODO')
end
---@param col number
---@return number,boolean
local function normalize_col(col)
    return col<0 and -1-col or col,col<0
end
---@param subranges ua.subranges
---@return fun():nil|number,number,boolean,boolean
function M.iter_subranges(subranges)
    assert(#subranges%2==0)
    return coroutine.wrap(function()
        for i=1,#subranges-1,2 do
            local col_start,start_inclusive=normalize_col(subranges[i])
            local col_end,end_inclusive=normalize_col(subranges[i+1])
            coroutine.yield(col_start,col_end,start_inclusive,end_inclusive)
        end
    end)
end
---@param subranges ua.subranges
---@return fun():nil|number,number,boolean,boolean
function M.rev_iter_subranges(subranges)
    assert(#subranges%2==0)
    return coroutine.wrap(function()
        for i=#subranges,2,-2 do
            local col_start,start_inclusive=normalize_col(subranges[i-1])
            local col_end,end_inclusive=normalize_col(subranges[i])
            coroutine.yield(col_start,col_end,start_inclusive,end_inclusive)
        end
    end)
end
return M
