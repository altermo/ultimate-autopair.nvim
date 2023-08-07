local M={}
M.I={match=function (str,line)
    return str==line:sub(1,#str)
end}
---@param pair prof.def.m.pair
---@param o core.o
---@param cols number
---@param cole number
---@param Icount number?
---@param ret_pos boolean?
---@return false|number
function M.count_start_pair(pair,o,cols,cole,Icount,ret_pos)
    local start_pair=pair.start_pair:reverse()
    local end_pair=pair.end_pair:reverse()
    local i=cole
    local count=Icount or 0
    local filter=function(_,_) return true end --TODO: temp
    while i>cols-1 do
        local line=o.line:sub(cols,i):reverse()
        if M.I.match(start_pair,line) and filter(i,i+#start_pair-1) then
            count=count-1
            i=i-#start_pair
        elseif M.I.match(end_pair,line) and filter(i,i+#end_pair-1) then
            count=count+1
            i=i-#end_pair
        else
            i=i-1
        end
        if ret_pos and count<=0 then
            return i
        elseif count<0 then
            count=0
        end
    end
    return (not ret_pos) and count
end
---@param pair prof.def.m.pair
---@param o core.o
---@param cols number
---@param cole number
---@param Icount number?
---@param ret_pos boolean?
---@return false|number
function M.count_end_pair(pair,o,cols,cole,Icount,ret_pos)
    local start_pair=pair.start_pair
    local end_pair=pair.end_pair
    local i=cols
    local count=Icount or 0
    local filter=function(_,_) return true end --TODO: temp
    while i<cole+1 do
        local line=o.line:sub(i,cole)
        if M.I.match(start_pair,line) and filter(i,i+#start_pair-1) then
            count=count+1
            i=i+#start_pair
        elseif M.I.match(end_pair,line) and filter(i,i+#end_pair-1) then
            count=count-1
            i=i+#end_pair
        else
            i=i+1
        end
        if ret_pos and count==0 then
            return i
        elseif count<0 then
            count=0
        end
    end
    return (not ret_pos) and count
end
---@param pair prof.def.m.pair
---@param o core.o
---@param cols number
---@param cole number
---@param Icount number?
---@return false|number
function M.count_ambigious_pair(pair,o,cols,cole,Icount)
    local i=cols
    local spair=pair.pair
    local count=Icount or 0
    local index
    local filter=function(_,_) return true end --TODO: temp
    while i<cole+1 do
        local line=o.line:sub(i,cole)
        if M.I.match(spair,line) and filter(i,i+#spair-1) then
            count=count+1
            if not index then index=i end
            i=i+#spair
        else
            i=i+1
        end
    end
    return count%2==1 and index
end

---@param pair prof.def.m.pair
---@param o core.o
---@param col number
---@return false|number
function M.open_end_pair_after(pair,o,col)
    local count=M.count_end_pair(pair,o,1,col-1)
    return M.count_end_pair(pair,o,col,#o.line,count+1,true)
end
---@param pair prof.def.m.pair
---@param o core.o
---@param _ number?
---@return false|number
function M.open_pair_ambigous(pair,o,_)
    return M.count_ambigious_pair(pair,o,1,#o.line)
end
---@param pair prof.def.m.pair
---@param o core.o
---@param col number
---@return false|number
function M.open_pair_ambigous_before(pair,o,col)
    return M.count_ambigious_pair(pair,o,1,col-1)
end
---@param pair prof.def.m.pair
---@param o core.o
---@param col number
---@return false|number
function M.open_pair_ambigous_after(pair,o,col)
    return M.count_ambigious_pair(pair,o,col,#o.line)
end
return M
