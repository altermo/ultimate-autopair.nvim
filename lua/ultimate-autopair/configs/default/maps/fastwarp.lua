local default=require 'ultimate-autopair.configs.default.utils'
local utils=require'ultimate-autopair.utils'
local M={}
M.ext={}
function M.ext.fastwarp_over_pair(o,ind,p)
    if o.col+#p~=ind then return end
    local pair=default.start_pair(ind,o.line,true)
    if not pair then return end
    if pair.rule and not pair.rule() then return end
    local matching_pair_pos=pair.fn.find_end_pair(pair.start_pair,pair.end_pair,o.line,ind+#pair.start_pair)
    if not matching_pair_pos then return end
    return utils.delete(0,#p)..utils.movel(matching_pair_pos-o.col-#p)..p..utils.moveh(#p),matching_pair_pos
end
function M.ext.fastwarp_next_to_start_pair(o,ind,p)
    if o.col+#p==ind then return end
    local pair=default.start_pair(ind,o.line,true)
    if not pair then return end
    if pair.rule and not pair.rule() then return end
    return utils.delete(0,#p)..utils.movel(ind-o.col-#p)..p..utils.moveh(#p)
end
function M.ext.fastwarp_next_to_end_pair(o,ind,p,m)
    if o.col+#p==ind and m.iconf.hopout then return end
    local pair=default.end_pair(ind,o.line)
    if not pair then return end
    if pair.rule and not pair.rule() then return end
    if o.col+#p==ind then return not m.iconf.hopout and 1 end
    return utils.delete(0,#p)..utils.movel(ind-o.col-#p)..p..utils.moveh(#p)
end
function M.ext.fastwarp_over_word(o,ind,p)
    local regex=vim.regex([[\w]])
    if not regex:match_str(o.line:sub(ind,ind)) then return end
    while regex:match_str(o.line:sub(ind,ind)) do
        ind=ind+1
    end
    return utils.delete(0,#p)..utils.movel(ind-o.col-#p)..p..utils.moveh(#p),ind
end
function M.fastwarp_end(o,p,m,nocursormove)
    if o.col~=#o.line+1-#p then
        return utils.delete(0,#p)..'<end>'..p..utils.moveh(#p),#o.line+1-#p-o.col
    end
    if not m.iconf.multiline then return end
    if nocursormove then return end
    if vim.fn.line('.')==vim.fn.line('$') or o.incmd then return end
    return utils.delete(0,#p)..'<down><home><C-v>'..p..utils.moveh(#p),0,1
end
function M.fastwarp(o,m,nocursormove)
    o.line=m.iconf.filter and o.line or o.wline
    o.col=m.iconf.filter and o.col or o.wcol
    local move
    if nocursormove then
        local spair=default.start_pair(o.col,o.line)
        if spair then
            move=spair.fn.find_end_pair(spair.start_pair,spair.end_pair,o.line,o.col)
            if move then
                move=move-o.col-#spair.end_pair
                o.col=o.col+move
            else
                nocursormove=false
            end
        else
            nocursormove=false
        end
    end
    local pair=default.end_pair(o.col,o.line)
    if not pair then return end
    local p=pair.pair
    if not pair.conf.fastwarp then return end
    if pair.rule and not pair.rule() then return end
    for i=o.col+#p,#o.line do
        local ind=i
        for _,v in pairs(M.ext) do
            local ret,s=v(o,ind,p,m)
            if ret==1 then return end
            if ret then
                if nocursormove then
                    return utils.movel(move)..ret..utils.moveh((s or ind)-o.col-#p)..utils.moveh(move)
                end
                return ret
            end
        end
    end
    local ret,s
    if not default.get_type_opt(pair,'ambigous') then
        ret,s=M.fastwarp_end(o,p,m,nocursormove)
    end
    if ret and nocursormove then
        return utils.movel(move)..ret..utils.moveh(s)..utils.moveh(move)
    end
    return ret
end
function M.wrapp_fastwarp(m,nocursormove)
    return function (o)
        if default.key_check_cmd(o,m.map,m.map,m.cmap,m.cmap) then
            return M.fastwarp(o,m,nocursormove or m.iconf.nocursormove)
        end
    end
end
function M.init(conf,mconf,ext)
    if conf.enable==false then return end
    if conf.enable_normal==false then return end
    local m={}
    m.iconf=conf
    m.conf=conf.conf or {}
    m.map=mconf.map~=false and conf.map
    m.cmap=mconf.cmap~=false and conf.cmap
    m.p=conf.p or 10
    m.extensions=ext
    m._type={[default.type_pair]={'fastwarp'}}
    m.check=M.wrapp_fastwarp(m)
    m.get_map=default.get_mode_map_wrapper(m.map,m.cmap)
    m.rule=function () return true end
    default.init_extensions(m,m.extensions)
    local check=m.check
    m.check=function (o)
        o.wline=o.line
        o.wcol=o.col
        if not default.key_check_cmd(o,m.map,m.map,m.cmap,m.cmap) then return end
        if not m.rule() then return end
        return check(o)
    end
    m.doc='autopairs fastwarp key map'
    if conf.do_nothing_if_fail then
        local n={}
        n.get_map=default.get_mode_map_wrapper(m.map,m.cmap)
        n.p=-1
        n.check=function (o)
            if default.key_check_cmd(o,m.map,m.map,m.cmap,m.cmap) then
                return ''
            end
        end
        n.map=m.map
        n.doc='autopairs fastwarp do nothing'
        return m,n
    end
    return m
end
return M
