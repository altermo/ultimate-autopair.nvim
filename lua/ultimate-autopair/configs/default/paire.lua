local open_pair=require'ultimate-autopair.configs.default.utils.open_pair'
local default=require'ultimate-autopair.configs.default.utils'
local utils=require'ultimate-autopair.utils'
local M={}
M.fn={
    check_start_pair=open_pair.check_start_pair,
    check_end_pair=open_pair.check_end_pair
}
M.check_wrapper=function (m)
    return function (o)
        if o.line:sub(o.col,o.col-1+#m.pair)~=m.pair then return end
        local count1=open_pair.count_start_pair(m.start_pair,m.end_pair,o.line,o.col,#o.line)
        local count2=open_pair.count_end_pair(m.start_pair,m.end_pair,o.line,1,o.col-1)
        if count1-count2~=0 then return end --TODO: fix bugs and move into open_pair
        return '\x1d'..utils.movel(#m.pair)
    end
end
M.newline_wrapper=function (m)
    return function(o)
        if m.pair==o.line:sub(o.col,o.col+#m.pair-1) then
            return '\r<end><up><end>\r'
        end
    end
end
M.backspace_wrapper=function (m)
    return function (o)
        if o.line:sub(o.col-#m.start_pair-#m.end_pair,o.col-1-#m.end_pair)==m.start_pair and m.end_pair==o.line:sub(o.col-#m.end_pair,o.col-1) then
            if not open_pair.open_end_pair_after(m.start_pair,m.end_pair,o.line,o.col) then
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
    m._type={[default.type_pair]={'pair','end'}}
    m.fn=M.fn

    m.check=M.check_wrapper(m)
    m.newline=M.newline_wrapper(m)
    m.backspace=M.backspace_wrapper(m)
    m.rule=function () return true end
    default.init_extensions(m,m.extensions)
    m.get_map=default.get_map_wrapper({q.cmap and 'c',(not q.nomap) and 'i'},m.key)
    m.sort=default.sort
    m.p=q.p or 10
    local check=m.check
    m.check=function (o)
        o.wline=o.line
        o.wcol=o.col
        if not default.key_check_cmd(o,m.key,q.map,q.cmap) then return end
        if not m.rule() then return end
        return check(o)
    end
    return m
end
return M
