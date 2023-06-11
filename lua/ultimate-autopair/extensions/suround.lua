local default=require'ultimate-autopair.configs.default.utils'
local utils=require'ultimate-autopair.utils'
return default.wrapp_old_extension(function(o,keyconf,_,pair_type,m)
    if not keyconf.dosuround then return end
    if pair_type~=1 then return end
    local pair=default.get_pairs_by_pos(o.col,o.line,true)[1]
    if not pair then return end
    if not vim.tbl_get(pair,'conf','suround') then return end
    if not m.fn.check_start_pair(m,o.line,o.col) then return end
    local index=pair.fn.find_end_pair(pair,o.line,o.col+#pair.pair)
    if index then
        return m.pair..utils.addafter(index-o.col+#pair.pair-1,m.end_pair)
    end
end)
