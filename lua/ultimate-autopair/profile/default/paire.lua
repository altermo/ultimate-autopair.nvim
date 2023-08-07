local default=require'ultimate-autopair.profile.default.utils'
local utils=require'ultimate-autopair.utils'
local open_pair=require'ultimate-autopair.profile.default.utils.open_pair'
local M={}
M.fn={
    can_check=function (m,o)
        if o.line:sub(o.col,o.col-1+#m.pair)~=m.pair then return end
        local count2=open_pair.count_start_pair(m,o,o.col,#o.line)
        --Same as: count_open_end_pair_after
        local count1=open_pair.count_end_pair(m,o,1,o.col-1)
        --Same as: count_open_start_pair_before
        if count1==0 or count1>count2 then return end
        return true
    end,
}
---@param m prof.def.m.pair
---@return core.check-fn
function M.check_wrapper(m)
    return function (o)
        if not m.fn.can_check(o) then return end
        return utils.movel(#m.pair)
    end
end
---@param q prof.def.q
---@return prof.def.m.pair
function M.init(q)
    local m={}
    m.start_pair=q.start_pair
    m.end_pair=q.end_pair
    m.pair=m.end_pair
    m.extensions=q.extensions
    m.conf=q.conf
    m.key=m.pair:sub(1,1)
    m[default.type_def]={'charins','pair','end'}
    m.mconf=q.mconf
    m.p=q.p
    m.doc=('autopairs end pair: %s,%s'):format(m.start_pair,m.end_pair)
    m.fn=default.init_fns(m,M.fn)

    m.check=M.check_wrapper(m)
    m.filter=default.def_filter_wrapper(m)
    m.get_map=default.def_pair_get_map_wrapper(m,q)
    m.sort=default.def_pair_sort
    default.extend_pair_filter_with_map_check(m)
    return m
end
return M
