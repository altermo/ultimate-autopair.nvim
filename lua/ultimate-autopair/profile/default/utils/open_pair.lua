local utils=require'ultimate-autopair.utils'
local M={}
---TODO: DEAD CODE
M.I={match=function (str,line)
    return str==line:sub(1,#str)
end}
---@param pair prof.def.m.start_pair
---@param o core.o
---@param col number
---@param gotostart "both"|boolean?
---@param Icount number?
---@param ret_pos boolean?
---@return false|number
---@return number?
function M.count_start_pair(pair,o,col,gotostart,Icount,ret_pos)
    local start_pair=pair.start_pair:reverse()
    local end_pair=pair.end_pair:reverse()
    local count=Icount or 0
    local sfilter=function(row,col_) return utils._filter_pos(pair.start_m.filter,o,col_,row) end
    local efilter=function(row,col_) return utils._filter_pos(pair.end_m.filter,o,col_,row) end
    local lines={o.line}
    local row=o.row
    if pair.multiline then
        lines=vim.fn.reverse(vim.list_slice(o.lines,(not gotostart) and o.row or nil,gotostart==true and o.row or nil))
    end
    if not gotostart then lines[#lines]=lines[#lines]:sub(col) end
    if gotostart==true then lines[1]=lines[1]:sub(1,col) end
    for rrow,line in ipairs(lines)do
        rrow=(pair.multiline and gotostart==true and row+1 or #o.lines+1)-rrow
        if not rrow==row then assert(o.lines[pair.multiline and rrow or row]==line) end
        local i=1
        local k
        local rline=line:reverse()
        local next_start_pair=rline:find(start_pair,i,true)
        local next_end_pair=rline:find(end_pair,i,true)
        while true do
            if next_start_pair and ((not next_end_pair) or next_start_pair<next_end_pair) then
                i=next_start_pair+#start_pair
                k=((not gotostart) and rrow==row and #o.lines[rrow] or #line)-next_start_pair+1
                if sfilter(rrow,k-#start_pair+1) then count=count-1 end
                next_start_pair=rline:find(start_pair,i,true)
            elseif next_end_pair then
                i=next_end_pair+#end_pair
                k=((not gotostart) and rrow==row and #o.lines[rrow] or #line)-next_end_pair+1
                if efilter(rrow,k-#end_pair+1) then count=count+1 end
                next_end_pair=rline:find(end_pair,i,true)
            else break end
            if ret_pos and count<=0 then
                return k,rrow
            elseif count<0 then
                count=0
            end
        end
    end
    return (not ret_pos) and count
end
---@param pair prof.def.m.end_pair
---@param o core.o
---@param col number
---@param gotoend "both"|boolean?
---@param Icount number?
---@param ret_pos boolean?
---@return false|number
---@return number?
function M.count_end_pair(pair,o,col,gotoend,Icount,ret_pos)
    local start_pair=pair.start_pair
    local end_pair=pair.end_pair
    local count=Icount or 0
    local sfilter=function(row,col_) return utils._filter_pos(pair.start_m.filter,o,col_,row) end
    local efilter=function(row,col_) return utils._filter_pos(pair.end_m.filter,o,col_,row) end
    local lines={o.line}
    local row=o.row
    if pair.multiline then
        lines=vim.list_slice(o.lines,gotoend==true and o.row or nil,(not gotoend) and o.row or nil)
    end
    if not gotoend then lines[#lines]=lines[#lines]:sub(1,col) end
    if gotoend==true then lines[1]=lines[1]:sub(col--[[@as number]]) end
    for rrow,line in ipairs(lines) do
        rrow=(pair.multiline and gotoend==true and row-1 or 0)+(rrow+(pair.multiline and 0 or row-1))
        if rrow~=row then assert(o.lines[pair.multiline and rrow or row]==line) end
        local i=1 --(gotoend==true and rrow==row and col) or 1
        local k
        local next_start_pair=line:find(start_pair,i,true)
        local next_end_pair=line:find(end_pair,i,true)
        while true do
            if next_start_pair and ((not next_end_pair) or next_start_pair<next_end_pair) then
                k=next_start_pair+(gotoend==true and rrow==row and col-1 or 0)
                i=next_start_pair+#start_pair
                if sfilter(rrow,k) then count=count+1 end
                next_start_pair=line:find(start_pair,i,true)
            elseif next_end_pair then
                k=next_end_pair+(gotoend==true and rrow==row and col-1 or 0)
                i=next_end_pair+#end_pair
                if efilter(rrow,k) then count=count-1 end
                next_end_pair=line:find(end_pair,i,true)
            else break end
            if ret_pos and count==0 then
                return k,rrow
            elseif count<0 then
                count=0
            end
        end
    end
    return (not ret_pos) and count
end
---@param pair prof.def.m.ambiguou_pair
---@param o core.o
---@param col number?
---@param gotoend "both"|boolean?
---@param Icount number?
---@param ret_pos boolean?
---@return number?
---@return number?
function M.count_ambiguous_pair(pair,o,col,gotoend,Icount,ret_pos)
    local spair=pair.pair
    local sfilter=function(row,col_) return utils._filter_pos(pair.start_m.filter,o,col_,row) end
    local efilter=function(row,col_)
        return utils._filter_pos(pair.end_m.filter,o,col_,row)
    end
    local count=Icount or 0
    local index
    local rowindex
    local lines={o.line}
    local row=o.row
    if pair.multiline then
        lines=vim.list_slice(o.lines,gotoend==true and o.row or nil,(not gotoend) and o.row or nil)
    end
    if not gotoend then lines[#lines]=lines[#lines]:sub(1,col) end
    if gotoend==true then lines[1]=lines[1]:sub(col--[[@as number]]) end
    for rrow,line in ipairs(lines) do
        rrow=(pair.multiline and gotoend==true and row-1 or 0)+(rrow+(pair.multiline and 0 or row-1))
        if not rrow==row then assert(o.lines[pair.multiline and rrow or row]==line) end
        local i=1
        while true do
            local pos=line:find(spair,i,true)
            if not pos then break end
            local k=pos+(gotoend==true and rrow==row and col-1 or 0)
            if ((count%2==1 and efilter(rrow,k)) or
                (count%2==0 and sfilter(rrow,k))) then
                count=count+1
                if not gotoend or not index then
                    index=k
                    rowindex=rrow
                end
            end
            i=pos+#spair
        end
    end
    if not ret_pos and count%2==0 then return end
    return index,rowindex
end

---@param pair prof.def.m.end_pair
---@param o core.o
---@param col number
---@return number|false
---@return number?
function M.open_end_pair_after(pair,o,col)
    local count=M.count_end_pair(pair,o,col-1)
    return M.count_end_pair(pair,o,col,true,count+1,true)
end
---@param pair prof.def.m.start_pair
---@param o core.o
---@param col number
---@return number|false
---@return number?
function M.open_start_pair_before(pair,o,col)
    local count=M.count_start_pair(pair,o,col)
    return M.count_start_pair(pair,o,col-1,true,count+1,true)
end
---@param pair prof.def.m.ambiguou_pair
---@param o core.o
---@param _ number?
---@return number?
---@return number?
function M.open_pair_ambiguous(pair,o,_)
    return M.count_ambiguous_pair(pair,o,nil,'both')
end
---@param pair prof.def.m.ambiguou_pair
---@param o core.o
---@param col number
---@return boolean?
function M.open_pair_ambiguous_before_and_after(pair,o,col)
    local count=M.count_ambiguous_pair(pair,o,col-1) and 1 or 0
    local end_count=M.count_ambiguous_pair(pair,o,col,true,count)
    return count==1 and not end_count
end
---@param pair prof.def.m.ambiguou_pair
---@param o core.o
---@param col number
---@return boolean?
function M.open_pair_ambiguous_before_nor_after(pair,o,col)
    local count=M.count_ambiguous_pair(pair,o,col-1) and 1 or 0
    local end_count=M.count_ambiguous_pair(pair,o,col,true,count)
    return not end_count and count~=1
end
return M
