---@alias prof.def.map.rfastwarp.conf prof.def.map.fastwarp.conf

local default=require 'ultimate-autopair.profile.default.utils'
local open_pair=require 'ultimate-autopair.profile.default.utils.open_pair'
local utils=require'ultimate-autopair.utils'
local M={}
---@type table<string,fun(o:core.o,ind:number,p:string,m:prof.def.m.map):core.act?,number?>
M.act={}
---@param o core.o
---@param ind number
---@param p string
---@return core.act?
---@return number?
function M.act.rfastwarp_under_pair(o,ind,p)
    if o.col-1~=ind then return end
    local spair,index,rindex=default.get_pair_and_start_pair_pos_from_end(o,ind,false)
    if not spair then return end
    return {
        {'delete',0,#p},
        {'k',o.row-rindex},
        {'home'},
        {'l',index-#spair.start_pair},
        p,{'h',#p}
    },o.row-rindex
end
---@param o core.o
---@param ind number
---@param p string
---@return core.act?
function M.act.rfastwarp_next_to_end_pair(o,ind,p)
    if o.col-1==ind then return end
    local pair=default.get_pairs_by_pos(o,ind,'end',true)[1]
    if not pair then return end
    return {
        {'delete',0,#p},
        {'h',o.col-ind-1},
        p,{'h',#p}
    }
end
---@param o core.o
---@param ind number
---@param p string
---@param m prof.def.m.map
---@return core.act?
function M.act.rfastwarp_next_to_start_pair(o,ind,p,m)
    if o.col-1==ind and m.iconf.hopout then return end
    local pair=default.get_pairs_by_pos(o,ind,'start',true)[1]
    if not pair then return end
    if default.get_type_opt(pair,'ambiguous') then
        if not open_pair.open_pair_ambiguous_before_nor_after(pair,o,ind) then return end
    end
    return {
        {'delete',0,#p},
        {'h',o.col-ind-#p},
        p,{'h',#p}
    }
end
---@param o core.o
---@param ind number
---@param p string
---@return core.act?
function M.act.rfastwarp_under_word(o,ind,p)
    if o.col-1==ind then return end
    local regex=vim.regex('^\\k') --[[@as vim.regex]]
    if not regex:match_str(o.line:sub(ind)) then return end
    if regex:match_str(o.line:sub(ind+1)) then return end
    return {
        {'delete',0,#p},
        {'h',o.col-ind-1},
        p,{'h',#p}
    }
end
---@param o core.o
---@param p string
function M.rfastwarp_start(o,p)
    if o.col==1 then return end
    return {
        {'delete',0,#p},
        {'home'},
        ''..p,{'h',#p}
    }
end
---@param o core.o
---@param p string
---@return core.act?
---@return number?
function M.rfastwarp_line(o,p)
    if o.col~=1 then return end
    if 1==o.row then return end
    return {
        {'delete',0,#p},
        {'k',1},
        {'end'},
        p,{'h',#p}
    },-1
end
---@param o core.o
---@param m prof.def.m.map
---@return string?
function M.rfastwarp(o,m)
    local new_o=o
    local nocurmove=m.iconf.nocursormove
    if nocurmove then
        local spair,index,rindex=default.get_pair_and_end_pair_pos_from_start(o,o.col,true)
        if spair then
            new_o=utils._get_o_pos(o,index,rindex)
        else
            nocurmove=false
        end
    end
    local pair=default.get_pairs_by_pos(new_o,new_o.col,'end',true,function (p)
        return p.conf.fastwarp~=false
    end)[1]
    if not pair then return end
    local p=pair.pair
    for ind=new_o.col-1,1,-1 do
        for _,v in pairs(M.act) do
            local ret,r=v(new_o,ind,p,m)
            if ret then
                if nocurmove then
                    return utils.create_act({
                        {'j',new_o.row-o.row},
                        {'home'},
                        {'l',new_o.col-1},
                        {'sub',ret},
                        {'k',new_o.row-o.row-(r or 0)},
                        {'home'},
                        {'l',o.col-1},
                    })
                end
                return utils.create_act(ret)
            end
        end
    end
    local ret,r=M.rfastwarp_start(new_o,p)
    if not ret and pair.multiline and m.iconf.multiline then
        ret,r=M.rfastwarp_line(new_o,p)
    end
    if ret then
        if nocurmove then
            return utils.create_act({
                {'j',new_o.row-o.row},
                {'home'},
                {'l',new_o.col-1},
                {'sub',ret},
                {'k',new_o.row-o.row+(r or 0)},
                {'home'},
                {'l',o.col-1},
            })
        end
        return utils.create_act(ret)
    end
end
---@param m prof.def.m.map
---@return core.check-fn
function M.wrapp_rfastwarp(m)
    return function (o)
        local ret=M.rfastwarp(o,m)
        local tsnode=default.load_extension'tsnode'
        o.save[tsnode.savetype]={_skip={}}
        return ret
    end
end
---@param conf prof.def.map.fastwarp.conf
---@param mconf prof.def.conf
---@param ext prof.def.ext[]
---@return prof.def.m.map?,prof.def.module?
function M.init(conf,mconf,ext)
    if conf.enable==false then return end
    if conf.enable_reverse==false then return end
    local m={}
    m.iconf=conf
    m.conf=conf.conf or {}
    m.map=mconf.map~=false and conf.rmap
    m.cmap=mconf.cmap~=false and conf.rcmap
    m.extensions=ext
    m[default.type_def]={'rfastwarp'}
    m.p=conf.p or mconf.p or 10
    m.doc='autopairs reverse fastwarp key map'

    m.check=M.wrapp_rfastwarp(m)
    m.filter=default.def_filter_wrapp(m)
    default.init_extensions(m,m.extensions)
    m.get_map=default.def_map_get_map_wrapp(m)
    default.extend_map_check_with_map_check(m,not conf.no_filter_nodes and function (o)
        local tsnode=default.load_extension'tsnode'
        o.save[tsnode.savetype]={_skip=conf.no_filter_nodes} --TODO: refactor {r}fastwarp.lua so that the option can be removed
        return true
    end or nil)
    if conf.do_nothing_if_fail then
        local n={}
        n.map=m.map
        n.cmap=m.cmap
        n.p=-1
        n.get_map=default.def_map_get_map_wrapp(n)
        n.filter=function () end
        n.check=function () return '' end
        default.extend_map_check_with_map_check(n)
        n.doc='autopairs reverse fastwarp do nothing'
        return m,n
    end
    return m
end
return M
