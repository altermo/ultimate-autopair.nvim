local info_line=require'ultimate-autopair.utils.info_line'
return {filter=function (o,conf)
    if #o.key>1 then return end
    local instring,strbeg,strend=info_line.in_string(o.line,o.col,nil,(conf or {}).notree)
    if instring then
        o.line=o.line:sub(strbeg+0,strend)
        o.col=o.col-strbeg+1
    else
        local newline=''
        local parser=pcall(vim.treesitter.get_parser)
        if not (conf or {}).notree and parser then
            for i=1,#o.line do
                local err,node=pcall(vim.treesitter.get_node_at_pos,0,o.linenr-1,i-1,{})
                if i==o.col then
                    o.col=#newline+1
                end
                if err and node:type()~='string' then
                    newline=newline..o.line:sub(i,i)
                elseif newline:sub(-1)~='\1' then
                    newline=newline..'\1'
                end
            end
            o.line=newline
            return
        end
        local escape=false
        for i=1,#o.line do
            local char=o.line:sub(i,i)
            if i==o.col then
                o.col=#newline+1
            end
            if not instring then
                newline=newline..char
            end
            if escape then
                escape=false
            elseif char=='"' then
                if char==instring then
                    newline=newline..char
                    instring=nil
                else
                    instring='"'
                end
            elseif char=="'" then
                if char==instring then
                    newline=newline..char
                    instring=nil
                else
                    instring="'"
                end
            elseif char=='\\' then
                escape=true
            end
        end
        o.line=newline
    end
end}
