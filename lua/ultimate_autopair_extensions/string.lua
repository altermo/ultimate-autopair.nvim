local info_line=require'ultimate-autopair.utils.info_line'
return {filter=function (o,conf)
    if #o.key>1 then return end
    o.line,o.col=info_line.filter_string(o.line,o.col,nil,(conf or {}).notree)
end}
