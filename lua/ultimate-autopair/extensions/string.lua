local M={}
function M.instring(line,col,linenr,notree)
    --TODO: refactor
    local instring
    local escape=false
    local parser=pcall(vim.treesitter.get_parser)
    local utils=require'ultimate-autopair.utils'
    if parser and not notree then
        local err,node=pcall(utils.gettsnode,linenr-1,col-1)
        if err then
            if node and vim.tbl_count({'string','raw_string'},node:type()) then
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
        if char=='"' then
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
        end
    end
    if instring then
        local strend=M.findstringe(line,col,instring,escape)
        if strend then
            return instring,strbeg,strend
        end
    end
end
function M.filter_out_string(line,col,linenr,notree)
    --TODO: refactor
    local instring
    local utils=require'ultimate-autopair.utils'
    local newline=''
    local parser=pcall(vim.treesitter.get_parser)
    if parser and not notree then
        for i=1,#line do
            local err,node=pcall(utils.gettsnode,linenr-1,i-1)
            if err and node and vim.tbl_count({'string','raw_string'},node:type()) then
                newline=newline..'\1'
            else
                newline=newline..line:sub(i,i)
            end
        end
    else
        for i=1,#line do
            local char=line:sub(i,i)
            if i==col then
                col=#newline+1
            end
            if instring then
                if char==instring then
                    newline=newline..char
                    instring=nil
                else
                    newline=newline..'\1'
                end
            end
            if (char=='"' or char=="'") then
                instring=char
                newline=newline..char
            else
                newline=newline..char
            end
        end
    end
    return newline,col
end
function M.filter_string(line,col,linenr,notree)
    --local instring,strbeg,strend=M.instring(line,col,linenr,notree)
    --if instring then
        --return line:sub(strbeg+0,strend),col-strbeg+1
    --end
    --return M.filter_out_string(line,col,linenr,notree)
    return line,col
end
function M.call(m,ext)
    local check=m.check
    m.check=function (o)
        o.line,o.col=M.filter_string(o.line,o.col,o.linenr,ext.notree)
        return check(o)
    end
end
return M
