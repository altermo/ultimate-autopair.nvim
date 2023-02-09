local open_pair=require'ultimate-autopair.utils.open_pair'
local utils=require'ultimate-autopair.utils.utils'
local info_line=require'ultimate-autopair.utils.info_line'
return {filter=function(o,conf)
    --TODO: don't use o.w* for detection. NEEDS: the string extension to leave in string delimiters
    local poschar=o.wline:sub(o.wcol,o.wcol)
    if o.type==1 and vim.tbl_contains(conf,poschar) then
        if not open_pair.open_pair_ambigous_before_and_after(poschar,o.wline,o.wcol) then
            local index=info_line.findstringe(o.wline,o.wcol+1,poschar)
            if index then
                return o.pair..utils.addafter(index-o.wcol+1,o.paire)
            end
        end
    end
end}
