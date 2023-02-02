return{
    init=function(keyconf,mem,conf,gmem)
        for k,v in pairs(keyconf) do
            mem[k]=v
        end
    end,
    filter=function(o,conf,mem,gmem)
    end}
