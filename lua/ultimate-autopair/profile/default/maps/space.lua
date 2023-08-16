---@class prof.def.map.space.conf:prof.def.conf.map
---@field check_box_ft string[]?

local default=require 'ultimate-autopair.profile.default.utils'
local utils=require 'ultimate-autopair.utils'
local M={}
---@param m prof.def.m.map
---@param o core.o
---@return string?
function M.space(o,m)
    local conf=m.iconf
    local pcol
    local total=0
    for i=o.col-1,1,-1 do
        if o.line:sub(i,i)~=' ' then
            pcol=i+1
            break
        end
        total=total+1
    end
    local prev_pair=default.get_pairs_by_pos(o,pcol,'start',false,function(pair)
        return pair.conf.space
    end)[1]
    if not prev_pair then return end
    if not o.incmd
        and (conf.check_box_ft==true or vim.tbl_contains(conf.check_box_ft or {},utils.getsmartft(o)))
        and vim.regex([=[\v^\s*([+*-]|(\d+\.))\s\[\]$]=]):match_str(o.line:sub(1,o.col)) then return end
    local index,rindex=prev_pair.fn.find_corresponding_pair(o,pcol-#prev_pair.start_pair)
    if not index then return end
    if rindex~=o.row then return end
    local ototal=#o.line:sub(o.col,index-1):reverse():match(' *')
    if ototal>total then return end
    return utils.create_act({
        ' ',
        {'l',index-o.col+#prev_pair.start_pair-#prev_pair.end_pair},
        (' '):rep(total-ototal+1),
        {'h',index-o.col+#prev_pair.start_pair-#prev_pair.end_pair+(total-ototal+1)},
    },o)
end
---@param m prof.def.m.map
---@return core.check-fn
function M.wrapp_space(m)
    return function (o)
        return M.space(o,m)
    end
end
---@param conf prof.def.map.space.conf
---@param mconf prof.def.conf
---@param ext prof.def.ext[]
---@return prof.def.m.map?
function M.init(conf,mconf,ext)
    if conf.enable==false then return end
    local m={}
    m.iconf=conf
    m.conf=conf.conf or {}
    m.map=mconf.map~=false and conf.map
    m.cmap=mconf.cmap~=false and conf.cmap
    m.extensions=ext
    m[default.type_def]={'space'}
    m.p=conf.p or mconf.p or 10
    m.doc='autopairs space key map'

    m.check=M.wrapp_space(m)
    m.filter=default.def_filter_wrapper(m)
    default.init_extensions(m,m.extensions)
    m.get_map=default.def_map_get_map_wrapper(m)
    default.extend_map_check_with_map_check(m)
    return m
end
return M
