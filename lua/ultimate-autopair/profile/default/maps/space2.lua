---@class prof.def.map.space2.conf:prof.def.conf.map
---@field match string?

local default=require 'ultimate-autopair.profile.default.utils'
local utils=require'ultimate-autopair.utils'
local core=require'ultimate-autopair.core'
local M={}
---@param _ prof.def.m.map
---@param o core.o
function M.space2(_,o)
    local total=0
    local pcol
    for i=o.col-1,1,-1 do
        if o.line:sub(i,i)~=' ' then
            pcol=i+1
            break
        end
        total=total+1
    end
    if not pcol then return end
    local prev_pair=default.get_pairs_by_pos(o,pcol,'start',false,function(pair)
        return pair.conf.space
    end)[1]
    if not prev_pair then return end
    local index,rindex=prev_pair.fn.find_corresponding_pair(o,pcol-#prev_pair.start_pair)
    if not index then return end
    if rindex~=o.row then return end
    local ototal=#o.line:sub(o.col,index-1):reverse():match(' *')
    if ototal>total then return end
    return utils.create_act({
        {'l',index-o.col+#prev_pair.start_pair-#prev_pair.end_pair},
        (' '):rep(total-ototal),
        {'h',index-o.col+#prev_pair.start_pair-#prev_pair.end_pair+(total-ototal)},
    })
end
---@param m prof.def.m.map
---@return core.check-fn
function M.space2_wrapp(m)
    return function(o)
        return M.space2(m,o)
    end
end
---@param m prof.def.m.map
---@return function
function M.wrapp_callback(m)
    return function ()
        if core.disable then return end
        if not vim.regex(m.iconf.match or [[\a]]):match_str(vim.v.char) then return end
        local o=core.get_o_value(vim.v.char)
        o.inoinit=true
        vim.api.nvim_feedkeys(m.check(o) or '','n',false)
    end
end
---@param conf prof.def.map.space2.conf
---@param mconf prof.def.conf
---@param ext prof.def.ext[]
---@return prof.def.m.map?
function M.init(conf,mconf,ext)
    if conf.enable==false then return end
    if mconf.map==false then return end
    local m={}
    m.iconf=conf
    m.conf=conf.conf or {}
    m.extensions=ext
    m[default.type_def]={'space2','charins'}
    m.p=conf.p or 10
    m.doc='autopairs autocmd for space2'

    m.check=M.space2_wrapp(m)
    m.oinit=function (delete)
        if delete then return end
        vim.api.nvim_create_autocmd('InsertCharPre',{callback=M.wrapp_callback(m),desc=m.doc,group='UltimateAutopair'})
    end
    m.filter=default.def_filter_wrapp(m)
    default.init_extensions(m,m.extensions)
    default.extend_map_check_in_oinit(m)
    return m
end
return M
