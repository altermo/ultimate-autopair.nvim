return{filter=function(o)
    if #o.key>1 then return end
    local i=o.col-1
    local escape=false
    while o.line:sub(i,i)=='\\' do
        i=i-1
        escape=not escape
    end
    if escape then return 2 end
end}
