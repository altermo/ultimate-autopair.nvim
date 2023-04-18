local M={}
M.I={}
function M.I.match (str,line)
    return str==line:sub(1,#str)
end

function M.count_start_pair(Istart_pair,Iend_pair,Iline,cols,cole,Icount,ret_pos)
    local start_pair=Istart_pair:reverse()
    local end_pair=Iend_pair:reverse()
    local i=cole
    local count=Icount or 0
    while i>cols-1 do
        local line=Iline:sub(0,i):reverse()
        if M.I.match(start_pair,line) then
            count=count-1
            i=i-#end_pair
        elseif M.I.match(end_pair,line) then
            count=count+1
            i=i-#start_pair
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
function M.count_end_pair(start_pair,end_pair,Iline,cols,cole,Icount,ret_pos)
    local i=cols
    local count=Icount or 0
    while i<cole+1 do
        local line=Iline:sub(i)
        if M.I.match(start_pair,line) then
            count=count+1
            i=i+#end_pair
        elseif M.I.match(end_pair,line) then
            count=count-1
            i=i+#start_pair
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
function M.count_ambigious_pair(pair,Iline,cols,cole,Icount)
    local i=cols
    local count=Icount or 0
    while i<cole+1 do
        local line=Iline:sub(i)
        if M.I.match(pair,line) then
            count=count+1
            i=i+#pair
        else
            i=i+1
        end
    end
    return count%2==1
end

function M.open_start_pair_before(start_pair,end_pair,line,col)
    local count=M.count_start_pair(start_pair,end_pair,line,col,#line)
    return M.count_start_pair(start_pair,end_pair,line,1,col-1,count+1,true)
end
function M.open_end_pair_after(start_pair,end_pair,line,col)
    local count=M.count_end_pair(start_pair,end_pair,line,1,col-1)
    return M.count_end_pair(start_pair,end_pair,line,col,#line,count+1,true)
end
function M.open_pair_ambigous_before(pair,line,col)
    return M.count_ambigious_pair(pair,line,1,col-1)
end
function M.open_pair_ambigous_after(pair,line,col)
    return M.count_ambigious_pair(pair,line,col,#line)
end
function M.open_pair_ambigous(pair,line,_)
    return M.count_ambigious_pair(pair,line,1,#line)
end

function M.check_start_pair(start_pair,end_pair,line,col)
    return not M.open_end_pair_after(start_pair,end_pair,line,col)
end
function M.check_end_pair(start_pair,end_pair,line,col)
    return not M.open_start_pair_before(start_pair,end_pair,line,col)
end
function M.check_ambiguous_end_pair(_,pair,line,col)
    local opab=M.open_pair_ambigous_before(pair,line,col)
    local opaa=M.open_pair_ambigous_after(pair,line,col)
    return opab and opaa and line:sub(col,col-1+#pair)==pair
end
function M.check_ambiguous_start_pair(pair,_,line,col)
    return not M.open_pair_ambigous(pair,line,col)
end

function M.find_corresponding_ambiguous_end_pair(pair,_,line,col)
    local opab=M.open_pair_ambigous_before(pair,line,col)
    local opaa=M.open_pair_ambigous_after(pair,line,col)
    if not (opab and opaa) then return end
    local i=col
    while i<#line+1 do
        if M.I.match(pair,line:sub(i)) then
            return i
        end
        i=i+1
    end
end
function M.find_corresponding_end_pair(start_pair,end_pair,line,col)
    return M.count_end_pair(start_pair,end_pair,line,col,#line,1,true)
end
return M
