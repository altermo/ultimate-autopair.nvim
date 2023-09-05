local default=require'ultimate-autopair.profile.default.utils'
local utils=require'ultimate-autopair.utils'
local open_pair=require'ultimate-autopair.profile.default.utils.open_pair'
local M={}
M.fn={
    can_check=function(m,o)
        if not m.fn.can_check_pre(o) then return end
        return open_pair.open_pair_ambiguous_before_and_after(m,o,o.col)
    end,
    can_check_pre=function (m,o)
        return o.line:sub(o.col,o.col-1+#m.pair)==m.pair
    end,
    find_corresponding_pair=function (m,o,col)
        local opaa,_=open_pair.count_ambiguous_pair(m,o,col+#m.pair,true)
        if  opaa then return end
        local opab,opabr=open_pair.count_ambiguous_pair(m,o,col-1,false,1,true)
        if not opab then return false end
        return opab,opabr
    end,
}
---@param m prof.def.m.pair
---@return core.check-fn
function M.check_wrapp(m)
    return function(o)
        if not m.fn.can_check(o) then return end
        return utils.create_act({{'l',#m.pair}})
    end
end
---@param m prof.def.m.pair
---@return prof.def.map.bs.fn
function M.backspace_wrapp(m)
    return function (o)
        if m.conf.backspace==false then return end
        if o.line:sub(o.col-#m.pair-#m.pair,o.col-1-#m.pair)==m.pair and
            m.pair==o.line:sub(o.col-#m.pair,o.col-1) and
            open_pair.open_pair_ambiguous_before_nor_after(m,o,o.col) and
            m.filter(utils._get_o_pos(o,o.col-#m.pair)) and
            m.filter(utils._get_o_pos(o,o.col-#m.pair-#m.pair)) then
            return utils.create_act({{'delete',#m.pair+#m.pair}})
        end
    end
end
---@param q prof.def.q
---@return prof.def.m.pair
function M.init(q)
    local m={}
    m.start_pair=q.start_pair
    m.end_pair=q.end_pair
    m.pair=q.end_pair
    m.extensions=q.extensions
    m.conf=q.conf
    m.key=m.pair:sub(1,1)
    m[default.type_def]={'charins','pair','end','ambiguous','dobackspace'}
    m.mconf=q.mconf
    m.p=q.p
    m.doc=('autopairs ambiguous end pair: %s'):format(m.pair)
    m.fn=default.init_fns(m,M.fn)
    m.multiline=q.multiline

    m.check=M.check_wrapp(m)
    m.backspace=M.backspace_wrapp(m)
    m.filter=default.def_filter_wrapp(m)
    default.init_extensions(m,m.extensions)
    m.get_map=default.def_pair_get_map_wrapp(m,q)
    m.sort=default.def_pair_sort
    default.extend_pair_check_with_map_check(m,q,function () return not m.conf.disable_end end)
    return m
end
return M
