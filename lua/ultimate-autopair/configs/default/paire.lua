local open_pair=require'ultimate-autopair.configs.default.utils.open_pair'
local default=require'ultimate-autopair.configs.default.utils'
local utils=require'ultimate-autopair.utils'
local M={}
M.fn={
    check_start_pair=function(m,line,col)
        return open_pair.check_start_pair(m,line,col)
    end,
    check_end_pair=function(m,line,col)
        return open_pair.check_end_pair(m,line,col)
    end,
    find_start_pair=function(m,o,col)
        return open_pair.find_corresponding_start_pair(m,o,col)
    end,
    is_start=function () return false end,
    is_end=function () return true end,
}
function M.check_wrapper(m)
    return function (o)
        if o.line:sub(o.col,o.col-1+#m.pair)~=m.pair then return end
        local count2=open_pair.count_start_pair(m,o,o.col,#o.line)
        local count1=open_pair.count_end_pair(m,o,1,o.col-1)
        if count1==0 or count1>count2 then return end
        return utils.movel(#m.pair)
    end
end
function M.newline_wrapper(m)
    return function(o)
        if m.pair==o.line:sub(o.col,o.col+#m.pair-1) and m.conf.newline then
            if open_pair.check_start_pair(m,o,o.col) then
                return '\r'..utils.key_end..utils.key_up..utils.key_end..'\r'
            end
        end
    end
end
function M.backspace_wrapper(m)
    return function (o)
        if o.line:sub(o.col-#m.start_pair-#m.end_pair,o.col-1-#m.end_pair)==m.start_pair and m.end_pair==o.line:sub(o.col-#m.end_pair,o.col-1) then
            if not open_pair.open_end_pair_after(m,o,o.col) then
                return utils.delete(#m.start_pair+#m.end_pair)
            end
        end
    end
end
function M.init(q)
    local m={}
    m.start_pair=q.start_pair
    m.end_pair=q.end_pair
    m.pair=m.end_pair
    m.extensions=q.extensions
    m.conf=q.conf
    m.key=m.pair:sub(1,1)
    m[default.type_pair]={'pair','end'}
    m.fn=default.init_fns(m,M.fn)
    m.mconf=q.mconf

    m.check=M.check_wrapper(m)
    m.newline=M.newline_wrapper(m)
    m.backspace=M.backspace_wrapper(m)
    m.rule=function () return true end
    m.filter=function () return true end
    default.init_extensions(m,m.extensions)
    m.get_map=default.get_map_wrapper({q.cmap and 'c',q.map and 'i'},m.key)
    m.sort=default.sort
    m.p=q.p or 10
    default.init_check_pair(m,q)
    m.doc=('autopairs end pair: %s,%s'):format(m.start_pair,m.end_pair)
    return m
end
return M
