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
        return open_pair.count_end_pair(m,o,col+#m.start_pair,true,1,true)
    end,
    can_check_pre=function(m,o)
        return o.line:sub(o.col-#m.pair+1,o.col-1)==m.pair:sub(0,-2)
    end
}
---@param m prof.def.m.pair
---@return core.check-fn
function M.check_wrapp(m)
    return function(o)
        if not m.fn.can_check(o) then return end
        return utils.create_act({
            m.start_pair:sub(-1),
            m.end_pair,
            {'h',#m.end_pair},
        })
    end
end
---@param m prof.def.m.pair
---@return prof.def.map.bs.fn
function M.backspace_wrapp(m)
    return function (o,_,conf)
        if o.line:sub(o.col-#m.start_pair,o.col-1)==m.start_pair and
            m.end_pair==o.line:sub(o.col,o.col+#m.end_pair-1) and
            m.filter(utils._get_o_pos(o,o.col-#m.pair)) and
            m.filter(utils._get_o_pos(o,o.col)) and
            not open_pair.open_start_pair_before(m,o,o.col) then
            return utils.create_act({{'delete',conf.single_delete and 1 or #m.start_pair,#m.end_pair}})
        end
        if o.line:sub(o.col-#m.start_pair,o.col-1)==m.start_pair and
            conf.overjumps and
            m.filter(utils._get_o_pos(o,o.col-#m.pair)) and
            not open_pair.open_start_pair_before(m,o,o.col) then
            local col,row=m.fn.find_corresponding_pair(o,o.col-#m.start_pair)
            if col then
                return utils.create_act({
                    {'j',row-o.row},
                    {'home'},
                    {'move',col-1},
                    {'delete',0,#m.end_pair},
                    {'k',row-o.row},
                    {'home'},
                    {'move',o.col-1},
                    {'delete',conf.single_delete and 1 or #m.start_pair},
                })
            end
        end
        if m.conf.newline==false then return end
        if o.incmd then return end
        if not m.multiline then return end
        if not conf.indent_ignore and 1~=o.col then return end
        local line1=o.lines[o.row-1]
        if not line1 then return end
        if line1:sub(-#m.start_pair)~=m.start_pair then return end
        if conf.indent_ignore and o.line:sub(1,o.col-1):find('[^%s]') then return end
        local line2=o.lines[o.row+1]
        if not line2 then return end
        local line2_start=line2:find('[^%s]')
        if not line2_start then return end
        if line2:sub(line2_start,line2_start+#m.end_pair-1)==m.end_pair and
            m.filter(utils._get_o_pos(o,#line1-#m.start_pair+1,o.row-1)) and
            m.filter(utils._get_o_pos(o,1,o.row+1)) then
            return utils.create_act({
                {'end'},
                {'delete',0,line2_start},
                {'k',1},
                {'end'},
                {'delete',0,o.col},
            })
        end
    end
end
---@param m prof.def.m.pair
---@return prof.def.map.cr.fn
function M.newline_wrapp(m)
    return function (o)
        if o.line:sub(o.col-#m.pair,o.col-1)==m.pair and m.conf.newline then
            local col,row=m.fn.find_corresponding_pair(o,o.col-#m.start_pair)
            if row~=o.row then return end
            if not m.filter(utils._get_o_pos(o,o.col-#m.pair)) then return end
            return utils.create_act({
                {'l',col-o.col},
                {'newline'},
                {'k'},
                {'home'},
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
    m.pair=m.start_pair
    m.extensions=q.extensions
    m.conf=q.conf
    m.key=m.pair:sub(-1)
    m[default.type_def]={'charins','pair','start','dobackspace','donewline'}
    m.mconf=q.mconf
    m.p=q.p
    m.doc=('autopairs start pair: %s,%s'):format(m.start_pair,m.end_pair)
    m.fn=default.init_fns(m,M.fn)
    m.multiline=q.multiline

    m.check=M.check_wrapp(m)
    m.filter=default.def_filter_wrapp(m)
    default.init_extensions(m,m.extensions)
    m.get_map=default.def_pair_get_map_wrapp(m,q)
    m.newline=M.newline_wrapp(m)
    m.backspace=M.backspace_wrapp(m)
    m.sort=default.def_pair_sort
    default.extend_pair_check_with_map_check(m,q,function () return not m.conf.disable_start end)
    return m
end
return M
