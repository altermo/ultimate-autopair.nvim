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
    return (not ret_pos) and count
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
    return (not ret_pos) and count
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
    local instring
    local escape=false
    local parser=pcall(vim.treesitter.get_parser)
    local utils=require'ultimate-autopair.utils.utils'
    if parser and not notree then
        local err,node=pcall(utils.gettsnode,linenr-1,col-1)
        if err then
            if node and node:type()=='string' then
                local _,column=node:start()
                if column+1~=col then
                    local _,strbeg,_,strend=node:range()
                    return true,strbeg+1,strend
                end
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
function M.findstring(line,cols,pair)
    for i=cols-1,1,-1 do
        local char=line:sub(i,i)
        if char==pair then
            local count=0
            while line:sub(i-count-1,i-count-1)=='\\' do
                count=count+1
            end
            if count%2==0 then
                return i
            end
        end
    end
end
function M.findepaire(line,col,pair,paire)
    return M.count_paire(pair,paire,line,col,#line,true,1)
end
function M.findpair(line,col,pair,paire)
    return M.count_pair(pair,paire,line,1,col-1,true,1)
end
function M.filter_string(line,col,linenr,notree)
    local instring,strbeg,strend=M.in_string(line,col,linenr,notree)
    if instring then
        return line:sub(strbeg+0,strend),col-strbeg+1
    else
        local utils=require'ultimate-autopair.utils.utils'
        local newline=''
        local parser=pcall(vim.treesitter.get_parser)
        if parser and not notree then
            for i=1,#line do
                local err,node=pcall(utils.gettsnode,linenr-1,i-1)
                if err and node and node:type()=='string' then
                    newline=newline..'\1'
                else
                    newline=newline..line:sub(i,i)
                end
            end
        else
            local escape=false
            for i=1,#line do
                local char=line:sub(i,i)
                if i==col then
                    col=#newline+1
                end
                if instring then
                    if char==instring and not escape then
                        newline=newline..char
                        instring=nil
                    else
                        newline=newline..'\1'
                    end
                    if escape then escape=false end
                elseif (char=='"' or char=="'") and not escape then
                    instring=char
                    newline=newline..char
                elseif char=='\\' and not escape then
                    escape=true
                    newline=newline..'\\'
                else
                    newline=newline..char
                    if escape then escape=false end
                end
            end
        end
        return newline,col
    end
end
return M
