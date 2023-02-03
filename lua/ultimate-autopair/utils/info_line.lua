local M={}
function M.count_pair(pair,paire,line,cols,cole,ret_pos,Icount)
    local count=Icount or 0
    for i=cole,cols,-1 do
        local char=line:sub(i,i)
        if char==pair then
            count=count-1
        elseif char==paire then
            count=count+1
        end
        if ret_pos and count==0 then
            return i
        end
        if count<0 then
            count=0
        end
    end
    return not ret_pos and count
end
function M.count_paire(pair,paire,line,cols,cole,ret_pos,Icount)
    local count=Icount or 0
    for i=cols,cole do
        local char=line:sub(i,i)
        if char==paire then
            count=count-1
        elseif char==pair then
            count=count+1
        end
        if ret_pos and count==0 then
            return i
        end
        if count<0 then
            count=0
        end
    end
    return not ret_pos and count
end
function M.count_ambigious_pair(pair,line,cols,cole,Icount)
    local count=Icount or 0
    for i=cols,cole do
        if line:sub(i,i)==pair then
            count=count+1
        end
    end
    return count%2==1
end
function M.in_string(line,col,linenr,notree)
    if vim.fn.mode()=='c' then return end
    local instring
    local escape=false
    local parser=pcall(vim.treesitter.get_parser)
    if parser and not notree then
        local err,node=pcall(vim.treesitter.get_node_at_pos,0,linenr or vim.fn.line('.')-1,col-1,{})
        if err and node and node:type()=='string' then
            local _,column=node:start()
            if column+1~=col then
                local _,strbeg,_,strend=node:range()
                return true,strbeg+1,strend
            end
            return
        end
    end
    local strbeg=-1
    if line:sub(1,3)=='"""' and vim.o.filetype=='python' then
        line=line:sub(2)
    end
    for i=1,col-1 do
        local char=line:sub(i,i)
        if escape then
            escape=false
        elseif char=='"' then
            if char==instring then
                instring=nil
            else
                instring='"'
                strbeg=i
            end
        elseif char=="'" then
            if char==instring then
                instring=nil
            else
                instring="'"
                strbeg=i
            end
        elseif char=='\\' then
            escape=true
        end
    end
    if instring then
        local strend=M.findstringe(line,col,instring,escape)
        if strend then
            return instring,strbeg,strend
        end
    end
end
function M.findstringe(line,cols,pair,escape)
    for i=cols,#line do
        local char=line:sub(i,i)
        if escape then
            escape=false
        elseif char==pair then
            return i
        elseif char=='\\' then
            escape=true
        end
    end
end
function M.findepaire(line,col,pair,paire)
    return M.count_paire(pair,paire,line,col,#line,true,1)
end
return M
