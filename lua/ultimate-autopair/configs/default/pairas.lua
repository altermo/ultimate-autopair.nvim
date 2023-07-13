local default=require'ultimate-autopair.configs.default.utils'
local open_pair=require'ultimate-autopair.configs.default.utils.open_pair'
local utils=require'ultimate-autopair.utils'
local M={}
M.fn={
    check_start_pair=function(m,line,col)
        return open_pair.check_ambiguous_start_pair(m.pair,nil,line,col)
    end,
    check_end_pair=function(m,line,col)
        return open_pair.check_ambiguous_end_pair(nil,m.pair,line,col)
    end,
    find_end_pair=function(m,line,col)
        return open_pair.find_corresponding_ambiguous_end_pair(m.pair,nil,line,col)
    end,
    find_start_pair=function(m,line,col)
        return open_pair.find_corresponding_ambiguous_start_pair(m.pair,nil,line,col)
    end,
    is_start=function (m,line,col) return not open_pair.open_pair_ambigous_before(m.pair,line,col) end,
    is_end=function (m,line,col) return false end,
    in_pair=function (m,line,col)
        local opab=open_pair.open_pair_ambigous_before(m.pair,line,col)
        local opaa=open_pair.open_pair_ambigous_after(m.pair,line,col)
        return opab and opaa,opab,(opaa or 0)+#m.pair-1
    end,
    in_pair_map=function (m,line)
        local i=1
        local map={false}
        local count=false
        local last=0
        while i<=#line do
            if m.pair==line:sub(i,i+#m.pair-1) then
                count=not count
                last=i
                i=i+#m.pair
                for j=i,i+#m.pair-1 do
                    map[j]=count
                end
            else
                i=i+1
                map[i]=count
            end
        end
        if count then
            for j=last,#map do
                map[j]=false
            end
        end
        return map
    end
}
function M.check_wrapper(m)
    return function(o)
        if not open_pair.check_ambiguous_start_pair(m.pair,m.end_pair,o.line,o.col) then return end
        if o.line:sub(o.col-#m.pair+1,o.col-1)~=m.pair:sub(0,-2) then return end
        return m.pair:sub(-1)..m.pair..utils.moveh(#m.pair)
    end
end
function M.newline_wrapper(m)
    return function (o)
        if o.line:sub(o.col-#m.pair,o.col-1)==m.pair and m.pair==o.line:sub(o.col,o.col+#m.pair-1) and m.conf.newline then
            return '\r'..utils.key_end..utils.key_up..utils.key_end..'\r'
        end
    end
end
function M.backspace_wrapper(m)
    return function (o,_,conf)
        if o.line:sub(o.col-#m.pair,o.col-1)==m.pair and m.pair==o.line:sub(o.col,o.col+#m.pair-1) then
            if not open_pair.open_pair_ambigous(m.pair,o.line,o.col) then
                return utils.delete(#m.pair,#m.pair)
            end
        end
        if conf.overjumps and m.conf.bs_overjumps then
            local opab=open_pair.open_pair_ambigous_before(m.pair,o.line,o.col)
            local opaa=open_pair.open_pair_ambigous_after(m.pair,o.line,o.col)
            if opaa and opab and o.line:sub(o.col-#m.pair,o.col-1)==m.pair then
                local matching_pair_pos=m.fn.find_end_pair(o.line,o.col)
                if matching_pair_pos then
                    return utils.delete(#m.start_pair)..utils.addafter(matching_pair_pos-o.col-1,utils.delete(0,#m.end_pair),0)
                end
            end
        end
        if o.incmd then return end
        if not conf.indent_ignore and 1~=o.col then return end
        if conf.indent_ignore and vim.trim(o.line:sub(1,o.col))~='' then return end
        local line1=utils.getline(o.linenr-1)
        local line2=utils.getline(o.linenr+1)
        if not line1 or not line2 then return end
        if line1:sub(-#m.start_pair)==m.start_pair and vim.trim(line2):sub(1,#m.end_pair)==m.end_pair then
            return utils.key_end..utils.delete(0,line2:find('[^%s]'))..utils.key_up..utils.key_end..utils.delete(0,o.col)
        end
    end
end
function M.init(q)
    local m={}
    m.pair=q.start_pair
    m.start_pair=m.pair
    m.end_pair=m.pair
    m.extensions=q.extensions
    m.conf=q.conf
    m.key=m.pair:sub(-1)
    m[default.type_pair]={'pair','ambigous-start'}
    m.fn=default.init_fns(m,M.fn)
    m.mconf=q.mconf

    m.check=M.check_wrapper(m)
    m.newline=M.newline_wrapper(m)
    m.backspace=M.backspace_wrapper(m)
    m.rule=function () return true end
    default.init_extensions(m,m.extensions)
    m.get_map=default.get_map_wrapper({q.cmap and 'c',q.map and 'i'},m.key)
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
    m.doc=('autopairs ambigous start pair: %s'):format(m.pair)
    return m
end
return M