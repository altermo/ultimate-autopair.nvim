local open_pair=require'ultimate-autopair.utils.open_pair'
local info_line=require'ultimate-autopair.utils.info_line'
local utils=require'ultimate-autopair.utils.utils'
return {filter=function(o,conf)
    local poschar=o.line:sub(o.col,o.col)
    if o.type==1 and vim.tbl_contains(conf,poschar) then
        if not open_pair.open_pair_ambigous_before_and_after(poschar,o.line,o.col) then
            local index=info_line.findstringe(o.wline,o.wcol+1,poschar)
            if index then
                utils.setline(o.wline:sub(1,o.wcol-1)..o.pair..o.wline:sub(o.wcol,index)..o.paire..o.wline:sub(index+1))
                utils.movel()
                return 1
            end
        end
    end
end}
