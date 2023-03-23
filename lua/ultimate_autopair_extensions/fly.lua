local open_pair=require'ultimate-autopair.utils.open_pair'
local utils=require'ultimate-autopair.utils.utils'
return {call=function (o,conf)
    if o.type==1 then return end
    if #o.key>1 then return end
    local next_char_index
    local line=conf.nofilter and o.wline or o.line
    local col=conf.nofilter and o.wcol or o.col
    for i=col,#line do
        local char=line:sub(i,i)
        if vim.tbl_contains(conf,char) or (conf.match and vim.regex(conf.match):match_str(char)) then
            if char==o.key then
                next_char_index=i
                break
            end
        else
            return
        end
    end
    if not next_char_index then return end
    if col==next_char_index then return end
    if o.type==3 then
        if not open_pair.open_pair_ambigous(o.pair,line,next_char_index) then
            return utils.movel(next_char_index-col+1)
        end
    else
        if not open_pair.open_pair_before(o.pair,o.paire,line,next_char_index) then
            return utils.movel(next_char_index-col+1)
        end
    end
end}
