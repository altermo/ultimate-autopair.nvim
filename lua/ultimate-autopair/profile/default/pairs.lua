local default=require'ultimate-autopair.profile.default.utils'
local utils=require'ultimate-autopair.utils'
local open_pair=require'ultimate-autopair.profile.default.utils.open_pair'
local M={}
M.fn={
    can_check=function (m,o)
        if not m.fn.can_check_pre(o) then return end
        if open_pair.open_end_pair_after(m,o,o.col) then return end
        return true
    end,
    find_corresponding_pair=function (m,o,col)
        return open_pair.open_end_pair_after(m,o,col+1)
    end,
    can_check_pre=function(m,o)
        return o.line:sub(o.col-#m.pair+1,o.col-1)==m.pair:sub(0,-2)
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
---@param m prof.def.m.pair
---@return prof.def.map.bs.fn
function M.backspace_wrapper(m)
    return function (o)
        if o.line:sub(o.col-#m.start_pair,o.col-1)==m.start_pair and m.end_pair==o.line:sub(o.col,o.col+#m.end_pair-1) then
            if m.filter(utils._get_o_pos(o,o.col-1)) then --TODO: maybe _get_o_pos is wrong and filter is the problem
                if not open_pair.open_start_pair_before(m,o,o.col) then
                    return utils.delete(#m.start_pair,#m.end_pair)
                end
            end
        end
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
    m[default.type_def]={'charins','pair','start','dobackspace'}
    m.mconf=q.mconf
    m.p=q.p
    m.doc=('autopairs start pair: %s,%s'):format(m.start_pair,m.end_pair)
    m.fn=default.init_fns(m,M.fn)
    m.multiline=q.multiline

    m.check=M.check_wrapper(m)
    m.filter=default.def_filter_wrapper(m)
    default.init_extensions(m,m.extensions)
    m.get_map=default.def_pair_get_map_wrapper(m,q)
    m.backspace=M.backspace_wrapper(m)
    m.sort=default.def_pair_sort
    default.extend_pair_check_with_map_check(m)
    return m
end
return M
