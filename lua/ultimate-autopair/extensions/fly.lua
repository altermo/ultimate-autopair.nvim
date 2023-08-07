local utils=require'ultimate-autopair.utils'
local default=require'ultimate-autopair.configs.default.utils'
local M={}
function M.check(conf,o,m)
    --TODO: don't just nofilter, create something better so that '"' "(|)" with " works
    local next_char_index
    local col=o.col
    if o.line:sub(col,col)==o.key then return end
    local i=col
    while i<=#o.line do
        local pair=default.end_pair(i,o,nil,function(p)
            return p.conf.fly
        end,nil,conf.nofilter)
        local is_start=false
        if not pair and not conf.only_jump_end_pair then
            pair=default.start_pair(i,o,true,function (p)
                return p.conf.fly
            end,nil,conf.nofilter)
            is_start=true
        end
        if not (vim.tbl_contains(conf.other_char,o.line:sub(i,i))
            or pair) then return end
        if not is_start and pair and pair.end_pair==m.end_pair then
            next_char_index=i
            break
        end
        i=i+(pair and #pair.pair or 1)
    end
    if not next_char_index then return end
    if m.fn.check_end_pair(vim.tbl_extend('force',o,{_nofilter=conf.nofilter}),i) then
        M.save={o.line,col,next_char_index-col+#m.pair,m.pair}
        return utils.movel(next_char_index-col+#m.pair)
    end
end
function M.map_wrapper(_)
    return function(o)
        local line=o.line
        local col=o.col
        if M.save[1]~=line or M.save[2]~=(col-M.save[3]) then return end
        return utils.moveh(M.save[3])..M.save[4]
    end
end
function M.init_map(ext,mconf)
    local conf=ext.conf or {}
    local mapconf=conf.undomapconf or {}
    local m={}
    m.map=mconf.map~=false and conf.undomap
    m.cmap=mconf.cmap~=false and ((conf.undocmap~=false and conf.undomap) or conf.undocmap)
    m.get_map=default.get_mode_map_wrapper(m.map,m.cmap)
    m.check=M.map_wrapper(conf)
    m.p=mapconf.p or 10
    m.rule=function () return true end
    m.filter=function () return true end
    local check=m.check
    m.check=function (o)
        o.wline=o.line
        o.wcol=o.col
        if not default.key_check_cmd(o,m.map,m.map,m.cmap,m.cmap) then return end
        if not m.rule() then return end
        return check(o)
    end
    if not m.map and not m.cmap and not mapconf.force_map then return end
    return m
end
function M.call(m,ext)
    if not m.conf.fly then return end
    if not default.get_type_opt(m,{'end','ambigous-end'}) then return end
    local check=m.check
    local conf=ext.conf
    m.check=function (o)
        local ret=M.check(conf,o,m)
        if ret then return ret end
        return check(o)
    end
end
return M
