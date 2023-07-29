local M={}
local default=require'ultimate-autopair.configs.default.utils'
local utils=require'ultimate-autopair.utils'
function M.check(o,m,_)
    if not m.conf.dosuround then return end
    local pair=default.start_pair(o.col,o,true,function(pair)
        return pair.conf.suround
    end)
    if not pair then return end
    local index=pair.fn.find_end_pair(o,o.col+#pair.pair)
    if index and m.fn.check_start_pair(o,o.col) then
        return m.pair:sub(-1)..utils.addafter(index-o.col+#pair.pair-1,m.end_pair)
    end
end
function M.call(m,ext)
    if not default.get_type_opt(m,{'start','ambigous-start'}) then return end
    local check=m.check
    m.check=function (o)
        local ret=M.check(o,m,ext)
        if ret then return ret end
        return check(o)
    end
end
return M
