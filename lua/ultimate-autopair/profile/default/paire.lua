local default=require'ultimate-autopair.profile.default.utils'
local utils=require'ultimate-autopair.utils'
local open_pair=require'ultimate-autopair.profile.default.utils.open_pair'
local M={}
M.fn={
    can_check=function (m,o)
        if not m.fn.can_check_pre(o) then return end
        local count2=open_pair.count_start_pair(m,o,o.col)
        --Same as: count_open_end_pair_after
        local count1=open_pair.count_end_pair(m,o,o.col-1)
        --Same as: count_open_start_pair_before
        if count1==0 or count1>count2 then return end
        return true
    end,
    find_corresponding_pair=function (m,o,col)
        return open_pair.count_start_pair(m,o,col-1,true,1,true)
    end,
    can_check_pre=function (m,o)
        return o.line:sub(o.col,o.col-1+#m.pair)==m.pair
    end
}
---@param m prof.def.m.pair
---@return core.check-fn
function M.check_wrapp(m)
    return function (o)
        if not m.fn.can_check(o) then return end
        return utils.create_act({{'l',#m.pair}})
    end
end
---@param m prof.def.m.pair
---@return prof.def.map.bs.fn
function M.backspace_wrapp(m)
    return function (o)
        if o.line:sub(o.col-#m.start_pair-#m.end_pair,o.col-1-#m.end_pair)==m.start_pair and
            m.end_pair==o.line:sub(o.col-#m.end_pair,o.col-1) and
            not open_pair.open_end_pair_after(m,o,o.col) then
            return utils.create_act({{'delete',#m.start_pair+#m.end_pair}})
        end
    end
end
---@param m prof.def.m.pair
---@return prof.def.map.cr.fn
function M.newline_wrapp(m)
    return function (o)
        if m.conf.newline==false then return end
        if m.pair==o.line:sub(o.col,o.col+#m.pair-1) and m.conf.newline then
            local _,row=m.fn.find_corresponding_pair(o,o.col)
            if row~=o.row then return end
            return utils.create_act({
                {'newline'},
                {'k'},
                {'l',o.col-1},
                {'newline'},
            })
        end
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
    m[default.type_def]={'charins','pair','end','dobackspace','donewline'}
    m.mconf=q.mconf
    m.p=q.p
    m.doc=('autopairs end pair: %s,%s'):format(m.start_pair,m.end_pair)
    m.fn=default.init_fns(m,M.fn)
    m.multiline=q.multiline

    m.check=M.check_wrapp(m)
    m.newline=M.newline_wrapp(m)
    m.backspace=M.backspace_wrapp(m)
    m.filter=default.def_filter_wrapp(m)
    default.init_extensions(m,m.extensions)
    m.get_map=default.def_pair_get_map_wrapp(m,q)
    m.sort=default.def_pair_sort
    default.extend_pair_check_with_map_check(m,q,function () return not m.conf.disable_end end)
    return m
end
return M
