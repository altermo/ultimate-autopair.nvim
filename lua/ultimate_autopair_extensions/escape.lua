return{filter=function(o)
    if #o.key>1 then return end
    local col=o.col-1
    local escape=false
    while o.line:sub(col,col)=='\\' do
        col=col-1
        escape=not escape
    end
    if escape then return 2 end
end}
