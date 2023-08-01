local default=require'ultimate-autopair.configs.default.utils'
local open_pair=require'ultimate-autopair.configs.default.utils.open_pair'
local utils=require'ultimate-autopair.utils'
local M={}
M.fn={
    check_start_pair=function(m,o,col)
        return open_pair.check_ambiguous_start_pair(m,o,col)
    end,
    check_end_pair=function(m,o,col)
        return open_pair.check_ambiguous_end_pair(m,o,col)
    end,
    find_end_pair=function(m,o,col)
        return open_pair.find_corresponding_ambiguous_end_pair(m,o,col)
    end,
    find_start_pair=function(m,o,col)
        return open_pair.find_corresponding_ambiguous_start_pair(m,o,col)
    end,
    is_start=function () return false end,
    is_end=function (m,line,col) return open_pair.open_pair_ambigous_before(m,line,col) end,
}
function M.check_wrapper(m)
    return function(o)
        if not open_pair.check_ambiguous_end_pair(m,o,o.col) then return end
        if o.line:sub(o.col,o.col-1+#m.pair)~=m.pair then return end
        return utils.movel(#m.pair)
    end
end
function M.backspace_wrapper(m)
    return function (o)
        if o.line:sub(o.col-#m.pair-#m.pair,o.col-1-#m.pair)==m.pair and m.pair==o.line:sub(o.col-#m.pair,o.col-1) then
            if open_pair.open_pair_ambigous_before(m,o,o.col)==open_pair.open_pair_ambigous_after(m,o,o.col) then
                return utils.delete(#m.pair+#m.pair)
            end
        end
    end
end
function M.init(q)
    local m={}
    m.pair=q.end_pair
    m.start_pair=m.pair
    m.end_pair=m.pair
    m.extensions=q.extensions
    m.conf=q.conf
    m.key=m.pair:sub(1,1)
    m[default.type_pair]={'pair','ambigous-end'}
    m.fn=default.init_fns(m,M.fn)
    m.mconf=q.mconf

    m.check=M.check_wrapper(m)
    --m.newline=M.newline_wrapper(m)
    m.backspace=M.backspace_wrapper(m)
    m.rule=function () return true end
    m.filter=function () return m.rule() end
    default.init_extensions(m,m.extensions)
    m.get_map=default.get_mode_map_wrapper(q.map and m.key,q.cmap and m.key)
    m.sort=default.sort
    m.p=q.p or 10
    default.init_check_pair(m,q)
    m.doc=('autopairs ambigous end pair: %s'):format(m.pair)
    return m
end
return M
