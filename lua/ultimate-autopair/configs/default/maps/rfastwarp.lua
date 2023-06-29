local default=require 'ultimate-autopair.configs.default.utils'
local utils=require'ultimate-autopair.utils'
local M={}
M.ext={}
function M.ext.rfastwarp_under_pair(o,ind,p)
    if o.col-1~=ind then return end
    local pair=default.end_pair(ind+1,o.line,true)
    if not pair then return end
    local matching_pair_pos=pair.fn.find_start_pair(o.line,ind-#pair.end_pair)
    if not matching_pair_pos then return end
    return utils.delete(0,#p)..utils.moveh(o.col-matching_pair_pos-1)..p..utils.moveh(#p),matching_pair_pos
end
function M.ext.rfastwarp_next_to_end_pair(o,ind,p)
    if o.col-1==ind then return end
    local pair=default.end_pair(ind+1,o.line,true)
    if not pair then return end
    return utils.delete(0,#p)..utils.moveh(o.col-ind-1)..p..utils.moveh(#p)
end
function M.ext.rfastwarp_next_to_start_pair(o,ind,p,m)
    if o.col-1==ind and m.iconf.hopout then return end
    local pair=default.start_pair(ind+1,o.line)
    if not pair then return end
    if o.col-1==ind then return not m.iconf.hopout and 1 end
    return utils.delete(0,#p)..utils.moveh(o.col-ind-1)..p..utils.moveh(#p)
end
function M.ext.rfastwarp_under_word(o,ind,p)
    if o.col-1==ind then return end
    local regex=vim.regex([[\w]])
    if not regex:match_str(o.line:sub(ind,ind)) then return end
    if regex:match_str(o.line:sub(ind+1,ind+1)) then return end
    return utils.delete(0,#p)..utils.moveh(o.col-ind-1)..p..utils.moveh(#p)
end
function M.rfastwarp_start(o,p,m)
    if o.col~=1 then
        return utils.delete(0,#p)..utils.key_home..''..p..utils.moveh(#p),o.col
    end
    if not m.iconf.multiline then return end
    if vim.fn.line('.')==1 or o.incmd then return end
    return utils.delete(0,#p)..utils.key_up..utils.key_end..p..utils.moveh(#p),0,1
end
function M.rfastwarp(o,m,nocursormove)
    o.line=m.iconf.filter and o.line or o.wline
    o.col=m.iconf.filter and o.col or o.wcol
    local move
    if nocursormove then
        local spair=default.start_pair(o.col,o.line)
        if spair then
            move=spair.fn.find_end_pair(o.line,o.col)
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
    local pair=default.end_pair(o.col,o.line,nil,function(pair)
        return pair.conf.fastwarp
    end)
    if not pair then return end
    local p=pair.pair
    for i=o.col-1,1,-1 do
        local ind=i
        for _,v in pairs(M.ext) do
            local ret,s=v(o,ind,p,m)
            if ret==1 then return end
            if ret then
                if nocursormove then
                    return utils.movel(move)..ret..utils.moveh(move-(o.col-(s or ind)-1))
                end
                return ret
            end
        end
    end
    return M.rfastwarp_start(o,p,m)
end
function M.wrapp_rfastwarp(m,nocursormove)
    return function (o)
        if default.key_check_cmd(o,m.map,m.map,m.cmap,m.cmap) then
            return M.rfastwarp(o,m,nocursormove or m.iconf.nocursormove)
        end
    end
end
function M.init(conf,mconf,ext)
    if conf.enable==false then return end
    if conf.enable_reverse==false then return end
    local m={}
    m.iconf=conf
    m.conf=conf.rconf or conf.conf or {}
    m.map=mconf.map~=false and conf.rmap
    m.cmap=mconf.cmap~=false and conf.rcmap
    m.p=conf.p or 10
    m.extensions=ext
    m._type={[default.type_pair]={'rfastwarp'}}
    m.check=M.wrapp_rfastwarp(m)
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
    m.doc='autopairs reverse fastwarp key map'
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
        n.doc='autopairs reverse fastwarp do nothing'
        return m,n
    end
    return m
end
return M
