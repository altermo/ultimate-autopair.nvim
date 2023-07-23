local default=require'ultimate-autopair.configs.default.utils'
local open_pair=require'ultimate-autopair.configs.default.utils.open_pair'
local utils=require'ultimate-autopair.utils'
local M={}
M.fn={
    check_start_pair=function(m,line,col)
        return open_pair.check_start_pair(m,line,col)
    end,
    check_end_pair=function(m,line,col)
        return open_pair.check_end_pair(m,line,col)
    end,
    find_end_pair=function(m,o,col)
        return open_pair.find_corresponding_end_pair(m,o,col)
    end,
    is_start=function () return true end,
    is_end=function () return false end,
}
function M.check_wrapper(m)
    return function (o)
        if o.line:sub(o.col-#m.pair+1,o.col-1)~=m.pair:sub(0,-2) then return end
        if open_pair.open_end_pair_after(m,o,o.col) then return end
        return m.start_pair:sub(-1)..m.end_pair..utils.moveh(#m.end_pair)
    end
end
function M.newline_wrapper(m)
    return function(o)
        if m.pair==o.line:sub(o.col-#m.pair,o.col-1) and m.conf.newline then
            local matching_pair_pos=m.fn.find_end_pair(o,o.col)
            if matching_pair_pos then
                return utils.movel(matching_pair_pos-o.col-1)..'\r'..utils.key_up..utils.key_home..utils.movel(o.col-1)..'\r'
            end
        end
    end
end
function M.backspace_wrapper(m)
    return function (o,_,conf)
        if o.line:sub(o.col-#m.start_pair,o.col-1)==m.start_pair and m.end_pair==o.line:sub(o.col,o.col+#m.end_pair-1) then
            if not open_pair.open_start_pair_before(m,o,o.col) then
                return utils.delete(#m.start_pair,#m.end_pair)
            end
        end
        if o.line:sub(o.col-#m.start_pair,o.col-1)==m.start_pair and conf.overjumps then
            if not open_pair.open_start_pair_before(m,o,o.col) then
                local matching_pair_pos=m.fn.find_end_pair(o,o.col)
                if matching_pair_pos then
                    return utils.delete(#m.start_pair)..utils.addafter(matching_pair_pos-o.col-1,utils.delete(0,#m.end_pair),0)
                end
            end
        end
        if o.incmd then return end
        if not m.conf.newline then return end
        if not conf.indent_ignore and 1~=o.col then return end
        if conf.indent_ignore and  vim.trim(o.line:sub(1,o.col))~='' then return end
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
    m.start_pair=q.start_pair
    m.end_pair=q.end_pair
    m.pair=m.start_pair
    m.extensions=q.extensions
    m.conf=q.conf
    m.key=m.pair:sub(-1)
    m[default.type_pair]={'pair','start'}
    m.fn=default.init_fns(m,M.fn)
    m.mconf=q.mconf

    m.check=M.check_wrapper(m)
    m.newline=M.newline_wrapper(m)
    m.backspace=M.backspace_wrapper(m)
    m.rule=function () return true end
    m.filter=function (_) return true end
    default.init_extensions(m,m.extensions)
    m.get_map=default.get_map_wrapper({q.cmap and 'c',q.map and 'i'},m.key)
    m.sort=default.sort
    m.p=q.p or 10
    default.init_check_pair(m,q)
    m.doc=('autopairs start pair: %s,%s'):format(m.start_pair,m.end_pair)
    return m
end
return M
