local default=require'ultimate-autopair.configs.default.utils'
local utils=require'ultimate-autopair.utils'
return default.wrapp_old_extension(function(o,keyconf,_,pair_type,m)
    if not keyconf.dosuround then return end
    if pair_type~=1 then return end
    local poschar=o.line:sub(o.col,o.col)
    local pair=default.get_pair(poschar)
    if not pair then return end
    if not vim.tbl_get(pair,'conf','suround') then return end
    if not m.fn.check_start_pair(m.start_pair,m.end_pair,o.line,o.col) then return end
    local index=pair.fn.find_end_pair(pair.pair,pair.end_pair,o.line,o.col+1)
    if index then
        return m.pair..utils.addafter(index-o.col,m.end_pair)
    end
end)
