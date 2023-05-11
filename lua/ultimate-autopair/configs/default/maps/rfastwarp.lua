local default=require 'ultimate-autopair.configs.default.utils'
local utils=require'ultimate-autopair.utils'
local M={}
M.ext={}
function M.ext.rfastwarp_under_pair(o,ind,p)
    if o.col-1~=ind then return end
    local pair=default.get_pair(o.line:sub(ind,ind))
    if not pair then return end
    if pair.rule and not pair.rule() then return end
    if not pair.fn.is_end(pair,o.line,ind) then return end
    local matching_pair_pos=pair.fn.find_start_pair(pair.start_pair,pair.end_pair,o.line,ind-1)
    if not matching_pair_pos then return end
    return utils.delete(0,1)..utils.moveh(o.col-matching_pair_pos-1)..p..utils.moveh(),matching_pair_pos-1
end
function M.ext.rfastwarp_next_to_end_pair(o,ind,p)
    if o.col-1==ind then return end
    local pair=default.get_pair(o.line:sub(ind,ind))
    if not pair then return end
    if pair.rule and not pair.rule() then return end
    if not pair.fn.is_end(pair,o) then return end
    return utils.delete(0,1)..utils.moveh(o.col-ind-1)..p..utils.moveh()
end
function M.ext.rfastwarp_next_to_start_pair(o,ind,p,m)
    if o.col-1==ind and m.iconf.hopout then return end
    local pair=default.get_pair(o.line:sub(ind,ind))
    if not pair then return end
    if pair.rule and not pair.rule() then return end
    if not default.get_type_opt(pair,'start') then return end
    if o.col-1==ind then return not m.iconf.hopout and 1 end
    return utils.delete(0,1)..utils.moveh(o.col-ind-1)..p..utils.moveh()
end
function M.ext.rfastwarp_under_word(o,ind,p)
    if o.col-1==ind then return end
    local regex=vim.regex([[\w]])
    if not regex:match_str(o.line:sub(ind,ind)) then return end
    if regex:match_str(o.line:sub(ind+1,ind+1)) then return end
    return utils.delete(0,1)..utils.moveh(o.col-ind-1)..p..utils.moveh()
end
function M.rfastwarp_start(o,p,m)
    if o.col~=1 then
        return utils.delete(0,1)..'<home><C-v>'..p..utils.moveh(),o.col-1
    end
    if not m.iconf.multiline then return end
    if vim.fn.line('.')==1 or o.incmd then return end
    return utils.delete(0,1)..'<up><end>'..p..utils.moveh(),0,1
end
function M.rfastwarp(o,m)
    local p=o.line:sub(o.col,o.col)
    local pair=default.get_pair(p)
    if not pair then return end
    if not pair.fn.is_end(pair,o) then return end
    if pair.rule and not pair.rule() then return end
    for i=o.col-1,1,-1 do
        local ind=i
        for _,v in pairs(M.ext) do
            local ret=v(o,ind,p,m)
            if ret==1 then return end
            if ret then return ret end
        end
    end
    return M.rfastwarp_start(o,p,m)
end
function M.wrapp_rfastwarp(m)
    return function (o)
        if default.key_check_cmd(o,m.map,m.map,m.cmap,m.cmap) then
            return M.rfastwarp(o,m)
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
        o.wcol=o.coll
        if not default.key_check_cmd(o,m.map,m.map,m.cmap,m.cmap) then return end
        check(o)
        if not m.rule() then return end
        return check(o)
    end
    if conf.do_nothing_if_fail then
        local n={}
        n.get_map=default.get_mode_map_wrapper(m.map,m.cmap)
        n.p=-1
        n.check=function (o)
            if default.key_check_cmd(o,m.map,m.map,m.cmap,m.cmap) then
                return ''
            end
        end
        return m,n
    end
    return m
end
return M
