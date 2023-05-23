local default=require'ultimate-autopair.configs.default.utils'
local open_pair=require'ultimate-autopair.configs.default.utils.open_pair'
local utils=require'ultimate-autopair.utils'
local M={}
M.fn={
    check_start_pair=open_pair.check_ambiguous_start_pair,
    check_end_pair=open_pair.check_ambiguous_end_pair,
    find_end_pair=open_pair.find_corresponding_ambiguous_end_pair,
    find_start_pair=open_pair.find_corresponding_ambiguous_start_pair,
    is_start=function (m,line,col) return not open_pair.open_pair_ambigous_before(m.pair,line,col) end,
    is_end=function (m,line,col) return open_pair.open_pair_ambigous_before(m.pair,line,col) end,
    in_pair=function (m,line,col)
        local opab=open_pair.open_pair_ambigous_before(m.pair,line,col)
        local opaa=open_pair.open_pair_ambigous_after(m.pair,line,col)
        return opab and opaa,opab,(opaa or 0)
    end
}
function M.check_start_wrapper(m)
    return function(o)
        if not open_pair.check_ambiguous_start_pair(m.pair,m.end_pair,o.line,o.col) then return end
        if o.line:sub(o.col-#m.pair+1,o.col-1)~=m.pair:sub(0,-2) then return end
        return '\x1d'..m.pair:sub(-1)..m.pair..utils.moveh(#m.pair)
    end
end
function M.check_end_wrapper(m)
    return function(o)
        if not open_pair.check_ambiguous_end_pair(m.start_pair,m.pair,o.line,o.col) then return end
        if o.line:sub(o.col,o.col-1+#m.pair)~=m.pair then return end
        return '\x1d'..utils.movel(#m.pair)
    end
end
function M.newline_wrapper(m)
    return function (o)
        if o.line:sub(o.col-#m.pair,o.col-1)==m.pair and m.pair==o.line:sub(o.col,o.col+#m.pair-1) and m.conf.newline then
            return '\r<end><up><end>\r'
        end
    end
end
function M.backspace_wrapper(m)
    return function (o)
        if o.line:sub(o.col-#m.pair-#m.pair,o.col-1-#m.pair)==m.pair and m.pair==o.line:sub(o.col-#m.pair,o.col-1) then
            if not open_pair.open_pair_ambigous(m.pair,o.line,o.col) then
                return utils.delete(#m.pair+#m.pair)
            end
        end
        if o.line:sub(o.col-#m.pair,o.col-1)==m.pair and m.pair==o.line:sub(o.col,o.col+#m.pair-1) then
            if not open_pair.open_pair_ambigous(m.pair,o.line,o.col) then
                return utils.delete(#m.pair,#m.pair)
            end
        end
    end
end
function M.init(q)
    local ms={}
    local me={}
    ms.pair=q.start_pair
    me.pair=q.end_pair
    me.ext_checks={}
    ms.ext_checks={}
    ms.extensions=q.extensions
    me.extensions=q.extensions
    ms.conf=q.conf
    me.conf=q.conf
    ms.key=ms.pair:sub(-1)
    me.key=me.pair:sub(1,1)
    ms._type={[default.type_pair]={'pair','ambigous-start'}}
    me._type={[default.type_pair]={'pair','ambigous-end'}}
    ms.fn=M.fn
    me.fn=M.fn

    ms.rule=function () return true end
    me.rule=function () return true end
    ms.check=M.check_start_wrapper(ms)
    me.check=M.check_end_wrapper(me)
    default.init_extensions(ms,ms.extensions)
    default.init_extensions(me,me.extensions)
    local m={}
    m.rule=function () return ms.rule() or me.rule() end
    m.get_map=default.get_map_wrapper({q.cmap and 'c',q.map and 'i'},ms.key,me.key)
    m.sort=default.sort
    m.p=q.p or 10
    m.ext_checks={}
    m.pair=q.start_pair
    m.start_pair=ms.pair
    m.end_pair=me.pair
    m.extensions=q.extensions
    m.conf=q.conf
    m._type={[default.type_pair]={'pair','ambigous'}}
    m.fn=M.fn
    m.backspace=M.backspace_wrapper(m)
    m.newline=M.newline_wrapper(m)
    m.check=function (o)
        if not m.rule() then return end
        o.wline=o.line
        o.wcol=o.col
        if default.key_check_cmd(o,me.key,q.map,q.cmap) and me.rule() then
            local ret=me.check(vim.deepcopy(o))
            if ret then return ret end
        end
        if default.key_check_cmd(o,ms.key,q.map,q.cmap) and ms.rule() then
            return ms.check(o)
        end
    end
    ms.doc=('autopairs ambigous start pair: %s'):format(m.pair)
    me.doc=('autopairs ambigous end pair: %s'):format(m.pair)
    m. doc=('autopairs ambigous pair: %s'):format(m.pair)
    return m,unpack(m.ext_checks),unpack(me.ext_checks),unpack(ms.ext_checks)
end
return M
