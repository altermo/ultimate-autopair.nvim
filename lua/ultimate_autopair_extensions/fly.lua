local open_pair=require'ultimate-autopair.utils.open_pair'
local utils=require'ultimate-autopair.utils.utils'
return {call=function (o,conf)
    if o.type~=2 then return end
    if #o.key>1 then return end
    local next_char_index
    local line=conf.nofilter and o.wline or o.line
    local col=conf.nofilter and o.wcol or o.col
    for i=col,#line do
        local char=line:sub(i,i)
        if char==o.key then
            next_char_index=i
            break
        elseif vim.tbl_contains(conf,char) then
        elseif conf.match and vim.regex(conf.match):match_str(char) then
        else
            return
        end
    end
    if not next_char_index then return end
    if col==next_char_index then return end
    if not open_pair.open_pair_before(o.pair,o.paire,line,next_char_index) then
        return utils.movel(next_char_index-col+1)
    end
end}
