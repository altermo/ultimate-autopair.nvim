local M={}
local default=require'ultimate-autopair.configs.default.utils.default'
local open_pair=require'ultimate-autopair.configs.default.utils.open_pair'
local utils=require'ultimate-autopair.utils'
M.I={}
function M.I.newline_wrapper(m)
    return function(o)
        if o.line:sub(o.col-#m.pair,o.col-1)==m.pair and m.pair==o.line:sub(o.col,o.col+#m.pair-1) then
            return '\r<end><up><end>\r'
        end
    end
end
M.fn={
    check_start_pair=open_pair.check_ambiguous_start_pair,
    check_end_pair=open_pair.check_ambiguous_end_pair,
    find_corresponding_end_pair=open_pair.find_corresponding_ambiguous_end_pair,
}
function M.init(q)
    local m={}
    m.pair=q.start_pair
    m.extensions=q.extensions
    m.conf=q.conf
    m.key1=m.pair:sub(-1)
    m.key2=m.pair:sub(1,1)
    m._type={[default.type_pair]={'pair','ambigous'}}
    m.fn=M.fn

    m.p=q.p or 10
    m.sort=default.sort
    m.get_map=default.get_map_wrapper({q.cmap and 'c',(not q.nomap) and 'i'},m.key1,m.key2)
    m.rule=function ()
        return true --TODO: implement
    end
    m.newline=M.I.newline_wrapper(m)
    m.backspace=function (o)
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
    function m.check(o)
        if o.key~=m.key1 and o.key~=m.key2 then --TODO: If cmap=false and incmd then return
            return
        end
        if not m.rule() then return end
        local flags=default.run_extensions(m,o,3)
        if type(flags)=='string' then return flags
        elseif flags.dont_pair then return end
        if o.key==m.key1 and not flags.dont_end_pair then
            local opab=open_pair.open_pair_ambigous_before(m.pair,o.line,o.col)
            local opaa=open_pair.open_pair_ambigous_after(m.pair,o.line,o.col)
            if opab and opaa and o.line:sub(o.col,o.col-1+#m.pair)==m.pair then
                return '\x1d'..utils.movel(#m.pair)
            end
        end
        if o.key==m.key2 and not flags.dont_start_pair then
            if not open_pair.open_pair_ambigous(m.pair,o.line,o.col) and o.line:sub(o.col-#m.pair+1,o.col-1)==m.pair:sub(0,-2) then
                return '\x1d'..m.pair:sub(-1)..m.pair..utils.moveh(#m.pair)
            end
        end
    end
    return m
end
return M
