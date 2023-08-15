---@class prof.def.map.fastwarp.conf:prof.def.conf.map
---@field enable_normal boolean?
---@field enable_reverse boolean?
---@field hopout boolean?
---@field rmap false?|string|string[]
---@field rcmap false?|string|string[]
---@field multiline boolean?
---@field nocursormove boolean?
---@field do_nothing_if_fail boolean?
---@field filter_string boolean? --TODO: make better so that string filter is not requires

local default=require 'ultimate-autopair.profile.default.utils'
local open_pair=require 'ultimate-autopair.profile.default.utils.open_pair'
local utils=require'ultimate-autopair.utils'
local M={}
---@type table<string,fun(o:core.o,ind:number,p:string,m:prof.def.m.map):table?,number?>
M.act={}
---@param o core.o
---@param ind number
---@param p string
---@return table?
---@return number?
function M.act.fastwarp_over_pair(o,ind,p)
    if o.col+#p~=ind then return end
    local spair,index,rindex=default.get_pair_and_end_pair_pos_from_start(o,ind)
    if not spair then return end
    return {
        {'delete',0,#p},
        {'j',rindex-o.row},
        {'home'},
        {'l',index-#p+#spair.end_pair-1},
        p,{'h',#p}
    },rindex-o.row
end
---@param o core.o
---@param ind number
---@param p string
---@return table?
function M.act.fastwarp_next_to_start_pair(o,ind,p)
    if o.col+#p==ind then return end
    local pair=default.get_pairs_by_pos(o,ind,'start',true)[1]
    if not pair then return end
    return {
        {'delete',0,#p},
        {'l',ind-o.col-#p},
        p,{'h',#p}
    }
end
---@param o core.o
---@param ind number
---@param p string
---@param m prof.def.m.map
---@return table?
function M.act.fastwarp_next_to_end_pair(o,ind,p,m)
    if o.col+#p==ind and m.iconf.hopout then return end
    local pair=default.get_pairs_by_pos(o,ind,'end',true)[1]
    if not pair then return end
    if default.get_type_opt(pair,'ambiguous') then
        if open_pair.open_pair_ambigous_before_nor_after(pair,o,ind) then return end
    end
    return {
        {'delete',0,#p},
        {'l',ind-o.col-#p},
        p,{'h',#p}
    }
end
---@param o core.o
---@param ind number
---@param p string
---@return table?
function M.act.fastwarp_over_word(o,ind,p)
    local regex=vim.regex('^\\k') --[[@as vim.regex]]
    if not regex:match_str(o.line:sub(ind)) then return end
    while regex:match_str(o.line:sub(ind)) do
        ind=ind+1
    end
    return {
        {'delete',0,#p},
        {'l',ind-o.col-#p},
        p,{'h',#p}
    }
end
---@param o core.o
---@param p string
---@return table?
function M.fastwarp_end(o,p)
    if o.col==#o.line+1-#p then return end
    return {
        {'delete',0,#p},
        {'end'},
        p,{'h',#p}
    }
end
---@param o core.o
---@param p string
---@return table?
---@return number?
function M.fastwarp_line(o,p,m)
    if o.col~=#o.line+1-#p then return end
    if not m.iconf.multiline then return end
    if #o.lines==o.row then return end
    return {
        {'delete',0,#p},
        {'j',1},
        {'home'},
        p,{'h',#p}
    },1
end
---@param o core.o
---@param m prof.def.m.map
---@return string?
function M.fastwarp(o,m)
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
        return p.conf.fastwarp
    end)[1]
    if not pair then return end
    local p=pair.pair
    for ind=new_o.col+#p,#new_o.line do
        for _,v in pairs(M.act) do
            local ret,r=v(new_o,ind,p,m)
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
                    },o)
                end
                return utils.create_act(ret,o)
            end
        end
    end
    local ret,r=M.fastwarp_end(o,p)
    if not ret and pair.multiline then
        ret,r=M.fastwarp_line(o,p,m)
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
            },o)
        end
        return utils.create_act(ret,o)
    end
end
---@param m prof.def.m.map
---@return core.check-fn
function M.wrapp_fastwarp(m)
    return function (o)
        return M.fastwarp(o,m)
    end
end
---@param conf prof.def.map.fastwarp.conf
---@param mconf prof.def.conf
---@param ext prof.def.ext[]
---@return prof.def.m.map?,prof.def.module?
function M.init(conf,mconf,ext)
    if conf.enable==false then return end
    if conf.enable_normal==false then return end
    local m={}
    m.iconf=conf
    m.conf=conf.conf or {}
    m.map=mconf.map~=false and conf.map
    m.cmap=mconf.cmap~=false and conf.cmap
    m.extensions=ext
    m[default.type_def]={'fastwarp'}
    m.p=conf.p or mconf.p or 10
    m.doc='autopairs fastwarp key map'

    m.check=M.wrapp_fastwarp(m)
    m.filter=default.def_filter_wrapper(m)
    if not conf.filter_string then
        for k,v in pairs(m.extensions) do
            if v.name=='tsnode' then
                local exte=vim.deepcopy(v)
                exte.conf.seperate=vim.tbl_filter(function (value)
                    return value~='string'
                end,exte.conf.seperate or {})
                m.extensions[k]=exte
                break
            end
        end
    end --TODO: refactor {r}fastwarp.lua so that the option can be removed

    default.init_extensions(m,m.extensions)
    m.get_map=default.def_map_get_map_wrapper(m)
    default.extend_map_check_with_map_check(m)
    if conf.do_nothing_if_fail then
        local n={}
        n.map=m.map
        n.cmap=m.cmap
        n.p=-1
        n.get_map=default.def_map_get_map_wrapper(n)
        n.filter=function () end
        n.check=function () return '' end
        default.extend_map_check_with_map_check(n)
        n.doc='autopairs fastwarp do nothing'
        return m,n
    end
    return m
end
return M
