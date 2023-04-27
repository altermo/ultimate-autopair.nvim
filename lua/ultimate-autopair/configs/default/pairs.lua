local M={}
local default=require'ultimate-autopair.configs.default.utils.default'
local open_pair=require'ultimate-autopair.configs.default.utils.open_pair'
local utils=require'ultimate-autopair.utils'
M.fn={
    check_start_pair=open_pair.check_start_pair,
    check_end_pair=open_pair.check_end_pair,
    find_end_pair=open_pair.find_corresponding_end_pair,
}
function M.init(q)
    local m={}
    m.start_pair=q.start_pair
    m.end_pair=q.end_pair
    m.extensions=q.extensions
    m.conf=q.conf
    m.pair=m.start_pair
    m.key=m.pair:sub(-1)
    m._type={[default.type_pair]={'pair','start'}}
    m.fn=M.fn

    m.p=q.p or 10
    m.sort=default.sort
    m.get_map=default.get_map_wrapper({q.cmap and 'c',(not q.nomap) and 'i'},m.key)
    m.rule=function ()
        return true --TODO: implement
    end
    m.newline=function (o)
        if m.pair==o.line:sub(o.col-#m.pair,o.col-1) and m.conf.newline then
            local matching_pair_pos=m.fn.find_end_pair(m.start_pair,m.end_pair,o.line,o.col)
            if matching_pair_pos then
                return utils.movel(matching_pair_pos-o.col-1)..'\r<up><home>'..utils.movel(o.col-1)..'\r'
            end
        end
    end
    m.backspace=function (o)
        if o.line:sub(o.col-#m.start_pair,o.col-1)==m.start_pair and m.end_pair==o.line:sub(o.col,o.col+#m.end_pair-1) then
            if not open_pair.open_start_pair_before(m.start_pair,m.end_pair,o.line,o.col) then
                return utils.delete(#m.start_pair,#m.end_pair)
            end
        end
        if o.line:sub(o.col-#m.start_pair,o.col-1)==m.start_pair then
            if not open_pair.open_start_pair_before(m.start_pair,m.end_pair,o.line,o.col) then
                local matching_pair_pos=m.fn.find_end_pair(m.start_pair,m.end_pair,o.line,o.col)
                if matching_pair_pos then
                    return utils.delete(#m.start_pair)..utils.addafter(matching_pair_pos-o.col-1,utils.delete(0,#m.end_pair),0)
                end
            end
        end
        if o.incmd then return end
        if vim.trim(o.line:sub(1,o.col))~='' then
            return
        end
        local line1=utils.getline(o.linenr-1)
        local line2=utils.getline(o.linenr+1)
        if not line1 or not line2 then
            return
        end
        if line1:sub(-1)==m.start_pair and vim.trim(line2):sub(1,1)==m.end_pair then
            return utils.delete(0,line2:find('[^%s]'))..'<up><end>'..utils.delete(0,o.col+1)
        end
    end
    function m.check(o)
        if o.key~=m.key then --TODO: If cmap=false and incmd then return
            return
        end
        if not m.rule() then return end
        local flags=default.run_extensions(m,o,1)
        if type(flags)=='string' then return flags
        elseif flags.dont_pair then return
        elseif flags.dont_start_pair then return end
        if not open_pair.open_end_pair_after(m.start_pair,m.end_pair,o.line,o.col) and o.line:sub(o.col-#m.pair+1,o.col-1)==m.pair:sub(0,-2) then
            return '\x1d'..m.start_pair:sub(-1)..m.end_pair..utils.moveh(#m.end_pair)
        end
    end
    return m
end
return M
