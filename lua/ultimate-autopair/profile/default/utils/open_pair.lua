local utils=require'ultimate-autopair.utils'
local M={}
M.I={match=function (str,line)
    return str==line:sub(1,#str)
end}
---@param pair prof.def.m.pair
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
    for rrow,line in ipairs(lines)do
        rrow=(pair.multiline and gotostart==true and row+1 or #o.lines+1)-rrow
        local i=(gotostart==true and rrow==row and col) or #line
        assert(o.lines[pair.multiline and rrow or row]==line)
        while ((not gotostart) and rrow==row and i>col-1) or ((gotostart or rrow~=row) and i>0) do
            local lline=line:sub((not gotostart) and rrow==row and col or 1,i):reverse()
            if M.I.match(start_pair,lline) and sfilter(rrow,i-#start_pair+1) then
                count=count-1
                i=i-#start_pair
            elseif M.I.match(end_pair,lline) and efilter(rrow,i-#end_pair+1) then
                count=count+1
                i=i-#end_pair
            else
                i=i-1
            end
            if ret_pos and count<=0 then
                return i+#start_pair,rrow
            elseif count<0 then
                count=0
            end
        end
    end
    return (not ret_pos) and count
end
---@param pair prof.def.m.pair
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
    for rrow,line in ipairs(lines) do
        rrow=(pair.multiline and gotoend==true and row-1 or 0)+(rrow+(pair.multiline and 0 or row-1))
        local i=(gotoend==true and rrow==row and col) or 1
        assert(o.lines[pair.multiline and rrow or row]==line)
        while ((not gotoend) and rrow==row and i<col+1) or ((gotoend or rrow~=row) and i<=#line) do
            local lline=line:sub(i,(not gotoend) and rrow==row and col or nil)
            if M.I.match(start_pair,lline) and sfilter(rrow,i) then
                count=count+1
                i=i+#start_pair
            elseif M.I.match(end_pair,lline) and efilter(rrow,i) then
                count=count-1
                i=i+#end_pair
            else
                i=i+1
            end
            if ret_pos and count==0 then
                return i-#end_pair,rrow
            elseif count<0 then
                count=0
            end
        end
    end
    return (not ret_pos) and count
end
---@param pair prof.def.m.pair
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
    for rrow,line in ipairs(lines) do
        rrow=(pair.multiline and gotoend==true and row-1 or 0)+(rrow+(pair.multiline and 0 or row-1))
        assert(o.lines[pair.multiline and rrow or row]==line)
        local i=(gotoend==true and rrow==row and col) or 1
        while ((not gotoend) and rrow==row and i<col+1) or ((gotoend or rrow~=row) and i<=#line) do
            local lline=line:sub(i,(not gotoend) and rrow==row and col or nil)
            if M.I.match(spair,lline) and
                ((count%2==1 and efilter(rrow,i)) or
                (count%2==0 and sfilter(rrow,i))) then
                count=count+1
                if not gotoend or not index then
                    index=i
                    rowindex=rrow
                end
                i=i+#spair
            else
                local i1=line:find(spair,i+1,true)
                i=i1 and i1 or #line+1
            end
        end
    end
    if not ret_pos and count%2==0 then return end
    return index,rowindex
end

---@param pair prof.def.m.pair
---@param o core.o
---@param col number
---@return number|false
---@return number?
function M.open_end_pair_after(pair,o,col)
    local count=M.count_end_pair(pair,o,col-1)
    return M.count_end_pair(pair,o,col,true,count+1,true)
end
---@param pair prof.def.m.pair
---@param o core.o
---@param col number
---@return number|false
---@return number?
function M.open_start_pair_before(pair,o,col)
    local count=M.count_start_pair(pair,o,col)
    return M.count_start_pair(pair,o,col-1,true,count+1,true)
end
---@param pair prof.def.m.pair
---@param o core.o
---@param _ number?
---@return number?
---@return number?
function M.open_pair_ambiguous(pair,o,_)
    return M.count_ambiguous_pair(pair,o,nil,'both')
end
---@param pair prof.def.m.pair
---@param o core.o
---@param col number
---@return boolean?
function M.open_pair_ambiguous_before_and_after(pair,o,col)
    local count=M.count_ambiguous_pair(pair,o,col-1) and 1 or 0
    local end_count=M.count_ambiguous_pair(pair,o,col,true,count)
    return count==1 and not end_count
end
---@param pair prof.def.m.pair
---@param o core.o
---@param col number
---@return boolean?
function M.open_pair_ambiguous_before_nor_after(pair,o,col)
    local count=M.count_ambiguous_pair(pair,o,col-1) and 1 or 0
    local end_count=M.count_ambiguous_pair(pair,o,col,true,count)
    return not end_count and count~=1
end
return M
