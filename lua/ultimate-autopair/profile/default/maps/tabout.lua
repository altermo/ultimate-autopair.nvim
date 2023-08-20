---@class prof.def.map.tabout.conf:prof.def.conf.map
---@field hopout boolean?
---@field do_nothing_if_fail boolean?

local default=require 'ultimate-autopair.profile.default.utils'
local utils=require 'ultimate-autopair.utils'
local M={}
---@param o core.o
---@param col number
---@param m prof.def.m.map
---@return string?
function M.tabout(o,col,m)
    local i=col
    while i<=#o.line do
        local end_pair=default.get_pairs_by_pos(o,i,'end',true)[1]
        if end_pair then
            local pcol=end_pair.fn.find_corresponding_pair(o,i)
            if pcol and pcol<col then
                if i==col then
                    if m.iconf.hopout then
                        return utils.create_act({{'l',#end_pair.pair}})
                    end
                else
                    return utils.create_act({
                        {'l',i-o.col}
                    })
                end
            end
            i=i+#end_pair.pair
        else
            i=i+1
        end
    end
end
---@param m prof.def.m.map
---@return core.check-fn
function M.wrapp_tabout(m)
    return function(o)
        return M.tabout(o,o.col,m)
    end
end
---@param conf prof.def.map.tabout.conf
---@param mconf prof.def.conf
---@param ext prof.def.ext[]
---@return prof.def.m.map?
---@return prof.def.m.map?
function M.init(conf,mconf,ext)
    if conf.enable==false then return end
    local m={}
    m.iconf=conf
    m.conf=conf.conf or {}
    m.map=mconf.map~=false and conf.map
    m.cmap=mconf.cmap~=false and conf.cmap
    m.extensions=ext
    m[default.type_def]={'tabout'}
    m.p=conf.p or mconf.p or 10
    m.doc='autopairs tabout key map'

    m.check=M.wrapp_tabout(m)
    m.filter=default.def_filter_wrapper(m)
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
        n.doc='autopairs close do nothing'
        return m,n
    end
    return m
end
return M
