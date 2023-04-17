local default=require'ultimate-autopair.configs.default.utils.default'
local utils=require'ultimate-autopair.utils'
return {call=function(o,keyconf,_,pair_type,m)
    --TODO: don't use o.w* for detection. NEEDS: the string extension to leave in string delimiters
    if not keyconf.dosuround then return end
    if pair_type~=1 then return end
    local poschar=o.wline:sub(o.wcol,o.wcol)
    local pair=default.get_pair(poschar)
    if not pair then return end
    if not vim.tbl_get(pair,'conf','suround') then return end
    if not m.fn.check_start_pair(m.start_pair,m.end_pair,o.line,o.col) then return end
    local index=pair.fn.find_corresponding_end_pair(pair.pair,pair.end_pair,o.wline,o.wcol+1)
    if index then
        return m.pair..utils.addafter(index-o.wcol+1,m.end_pair)
    end
end}
