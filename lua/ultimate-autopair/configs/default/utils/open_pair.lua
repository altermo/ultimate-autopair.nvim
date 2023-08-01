local default=require'ultimate-autopair.configs.default.utils'
local M={}
M.I={}
function M.I.match (str,line)
    return str==line:sub(1,#str)
end

function M.count_start_pair(pair,o,cols,cole,Icount,ret_pos)
    local start_pair=pair.start_pair:reverse()
    local end_pair=pair.end_pair:reverse()
    local i=cole
    local count=Icount or 0
    local filter=default.wrapp_pair_filter(o,pair.filter)
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
function M.count_end_pair(pair,o,cols,cole,Icount,ret_pos)
    local start_pair=pair.start_pair
    local end_pair=pair.end_pair
    local i=cols
    local count=Icount or 0
    local filter=default.wrapp_pair_filter(o,pair.filter)
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
function M.count_ambigious_pair(pair,o,cols,cole,Icount)
    local i=cols
    local filter=default.wrapp_pair_filter(o,pair.filter)
    pair=pair.pair
    local count=Icount or 0
    local index
    while i<cole+1 do
        local line=o.line:sub(i,cole)
        if M.I.match(pair,line) and filter(i,i+#pair-1) then
            count=count+1
            if not index then index=i end
            i=i+#pair
        else
            i=i+1
        end
    end
    return count%2==1 and index
end

function M.open_start_pair_before(pair,o,col)
    local count=M.count_start_pair(pair,o,col,#o.line)
    return M.count_start_pair(pair,o,1,col-1,count+1,true)
end
function M.open_end_pair_after(pair,o,col)
    local count=M.count_end_pair(pair,o,1,col-1)
    return M.count_end_pair(pair,o,col,#o.line,count+1,true)
end
function M.open_pair_ambigous_before(pair,o,col)
    return M.count_ambigious_pair(pair,o,1,col-1)
end
function M.open_pair_ambigous_after(pair,o,col)
    return M.count_ambigious_pair(pair,o,col,#o.line)
end
function M.open_pair_ambigous(pair,o,_)
    return M.count_ambigious_pair(pair,o,1,#o.line)
end

function M.check_start_pair(pair,o,col)
    if o.line:sub(col-#pair.pair+1,col-1)~=pair.pair:sub(0,-2) then return end
    return not M.open_end_pair_after(pair,o,col)
end
function M.check_end_pair(pair,o,col)
    if o.line:sub(col,col-1+#pair.pair)~=pair.pair then return end
    local count2=M.count_start_pair(pair,o,col,#o.line)
    local count1=M.count_end_pair(pair,o,1,col-1)
    if count1==0 or count1>count2 then return end
    return true
end
function M.check_ambiguous_end_pair(pair,o,col)
    local opab=M.open_pair_ambigous_before(pair,o,col)
    local opaa=M.open_pair_ambigous_after(pair,o,col)
    return opab and opaa
end
function M.check_ambiguous_start_pair(pair,o,col)
    return not M.open_pair_ambigous(pair,o,col)
end

function M.find_corresponding_ambiguous_end_pair(pair,o,col)
    local opab=M.open_pair_ambigous_before(pair,o,col)
    local opaa=M.open_pair_ambigous_after(pair,o,col)
    if not opab==opaa then return end
    local filter=default.wrapp_pair_filter(o,pair.filter)
    pair=pair.pair
    for i=col,#o.line do
        if M.I.match(pair,o.line:sub(i)) and filter(i,i+#pair-1) then
            return i+1
        end
    end
end
function M.find_corresponding_ambiguous_start_pair(pair,o,col)
    local opab=M.open_pair_ambigous_before(pair,o,col)
    local opaa=M.open_pair_ambigous_after(pair,o,col)
    if not opab==opaa then return end
    local filter=default.wrapp_pair_filter(o,pair.filter)
    for i=col,1,-1 do
        if M.I.match(pair.pair,o.line:sub(i)) and filter(i,i+#pair-1) then
            return i-1
        end
    end
end
function M.find_corresponding_end_pair(pair,o,col)
    return M.count_end_pair(pair,o,col,#o.line,1,true)
end
function M.find_corresponding_start_pair(pair,o,col)
    return M.count_start_pair(pair,o,1,col,1,true)
end
return M
