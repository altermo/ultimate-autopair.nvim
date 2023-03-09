return{call=function(o,conf)
    if #o.key>1 then return end
    local col=o.col-1
    local escape=false
    while o.line:sub(col,col)=='\\' do
        col=col-1
        escape=not escape
    end
    if escape then return 2 end
    if conf.filter then
        local newline=''
        escape=false
        for i=1,#o.line do
            local char=o.line:sub(i,i)
            if escape then
                escape=false
                newline=newline..'\1'
            elseif char=='\\' then
                escape=true
                newline=newline..char
            else
                newline=newline..char
            end
        end
        o.line=newline
    end
end}
