local utils=require'ultimate-autopair.utils'
local default=require'ultimate-autopair.configs.default.utils'
local M={}
--TODO: implement undo fly keymap
function M.check(conf,o,m)
    local next_char_index
    local line=conf.nofilter and o.wline or o.line
    local col=conf.nofilter and o.wcol or o.col
    if line:sub(col,col)==o.key then return end
    for i=col,#line do
        local char=line:sub(i,i)
        if vim.tbl_contains(conf.other_char,char)
            or vim.tbl_get(default.get_pair(char) or {},'conf','fly') then
            if char==o.key then
                next_char_index=i
                break
            end
        else
            return
        end
    end
    if not next_char_index then return end
    if m.fn.check_end_pair(m.start_pair,m.pair,line,col) then
        M.save={line,col,next_char_index-col+1,m.pair}
        return utils.movel(next_char_index-col+1)
    end
end
function M.map_wrapper(conf)
    return function(o)
        local line=conf.nofilter and o.wline or o.line
        local col=conf.nofilter and o.wcol or o.col
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
    local check=m.check
    local conf=ext.conf
    if not m.conf.fly then return end
    if not default.get_type_opt(m,{'end','ambigous-end'}) then return end
    m.check=function (o)
        local ret=M.check(conf,o,m)
        if ret then return ret end
        return check(o)
    end
end
return M
