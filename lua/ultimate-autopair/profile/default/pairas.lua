local default=require'ultimate-autopair.profile.default.utils'
local utils=require'ultimate-autopair.utils'
local open_pair=require'ultimate-autopair.profile.default.utils.open_pair'
local M={}
M.fn={
    can_check=function(m,o)
        if o.line:sub(o.col-#m.pair+1,o.col-1)~=m.pair:sub(0,-2) then return end
        return not open_pair.open_pair_ambigous(m,o)
    end
}
---@param m prof.def.m.pair
---@return core.check-fn
function M.check_wrapper(m)
    return function(o)
        if not m.fn.can_check(o) then return end
        return m.start_pair:sub(-1)..m.end_pair..utils.moveh(#m.end_pair)
    end
end
---@param q prof.def.q
---@return prof.def.m.pair
function M.init(q)
    local m={}
    m.start_pair=q.start_pair
    m.end_pair=q.end_pair
    m.pair=m.start_pair
    m.extensions=q.extensions
    m.conf=q.conf
    m.key=m.pair:sub(-1)
    m[default.type_def]={'charins','pair','start','ambiguous'}
    m.mconf=q.mconf
    m.p=q.p
    m.doc=('autopairs ambigous start pair: %s'):format(m.pair)
    m.fn=default.init_fns(m,M.fn)

    m.check=M.check_wrapper(m)
    m.filter=default.def_filter_wrapper(m)
    m.get_map=default.def_pair_get_map_wrapper(m,q)
    m.sort=default.def_pair_sort
    default.extend_pair_filter_with_map_check(m)
    return m
end
return M