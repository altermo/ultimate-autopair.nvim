local M={}
local open_pair=require'ultimate-autopair.pair.default.utils.open_pair'
local default=require'ultimate-autopair.pair.default.utils.default'
local utils=require'ultimate-autopair.utils'
M.fn={
    check_start_pair=open_pair.check_start_pair,
    check_end_pair=open_pair.check_end_pair
}
function M.init(q)
    local m={}
    m.start_pair=q.start_pair
    m.end_pair=q.end_pair
    m.pair=m.end_pair
    m.extensions=q.extensions
    m.conf=q.conf
    m.key=m.pair:sub(1,1)
    m._type={default.type_pair}
    m.fn=M.fn

    m.p=q.p or 10
    m.sort=default.sort
    m.get_map=default.get_map_wrapper({q.cmap and 'c',(not q.nomap) and 'i'},m.key)
    m.backspace=function (o)
        if o.line:sub(o.col-#m.start_pair-#m.end_pair,o.col-1-#m.end_pair)==m.start_pair and m.end_pair==o.line:sub(o.col-#m.end_pair,o.col-1) then
            if not open_pair.open_end_pair_after(m.start_pair,m.end_pair,o.line,o.col) then
                return utils.delete(#m.start_pair+#m.end_pair)
            end
        end
    end
    function m.check(o)
        if o.key~=m.key then
            return
        end
        local flags=default.run_extensions(m,o,2)
        if type(flags)=='string' then return flags
        elseif flags.dont_pair then return
        elseif flags.dont_end_pair then return end
        if o.line:sub(o.col,o.col-1+#m.pair)==m.pair then
            if not open_pair.open_start_pair_before(m.start_pair,m.end_pair,o.line,o.col) then
                return '\x1d'..utils.movel(#m.pair)
            end
        end
    end
    return m
end
return M
