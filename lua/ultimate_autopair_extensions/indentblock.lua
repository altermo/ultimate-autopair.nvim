local utils=require'ultimate-autopair.utils.utils'
return{call=function (o)
    if o.cmdmode then return end
    local indent=utils.getindent(o.linenr)
    if indent==0 or indent==-1 then return end
    local indentstart=o.linenr
    local prevlines={}
    local nextlines={}
    local indentend=o.linenr
    while utils.getindent(indentstart-1)==indent do
        indentstart=indentstart-1
        prevlines[#prevlines+1]=utils.getline(indentstart)
    end
    while utils.getindent(indentend+1)==indent do
        indentend=indentend+1
        nextlines[#nextlines+1]=utils.getline(indentend)
    end
    local prevline=vim.fn.join(prevlines,'\n')
    local nextline=vim.fn.join(nextlines,'\n')
    o.col=#prevline+o.col
    o.line=prevline..'\n'..o.line..'\n'..nextline
end}
