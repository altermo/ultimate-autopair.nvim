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
    local fcol=o.line:reverse():find('[^ ]',#o.line-o.col+2)
    if not fcol then return end
    local pcol=#o.line-fcol+2
    local total=o.col-pcol
    local prev_pair=default.get_pairs_by_pos(o,pcol,'start',false,function(pair)
        return pair.conf.space
    end)[1]
    if not prev_pair then return end
    if (conf.check_box_ft==true or vim.tbl_contains(conf.check_box_ft or {},utils.getsmartft(o)))
        and vim.regex([=[\v^\s*([+*-]|(\d+\.))\s\[\]$]=]):match_str(o.line:sub(1,o.col)) then return end
    if (conf._check_box_ft2==true or vim.tbl_contains(conf._check_box_ft2 or {},utils.getsmartft(o)))
        and vim.regex([=[\v^\s*([+*-]|(\d+\.))\s\(\)$]=]):match_str(o.line:sub(1,o.col)) then return end
    local index,rindex=prev_pair.fn.find_corresponding_pair(o,pcol-#prev_pair.start_pair)
    if not index then return end
    if rindex~=o.row then return end
    local ototal=#o.line:sub(o.col,index-1):reverse():match(' *')
    if ototal>total then return end
    return utils.create_act({
        ' ',
        {'l',index-o.col},
        (' '):rep(total-ototal+1),
        {'h',index-o.col+(total-ototal+1)},
    })
end
---@param m prof.def.m.map
---@return core.check-fn
function M.wrapp_space(m)
    return function (o)
        return M.space(o,m)
    end
end
---@type prof.def.map.bs.fn
function M.backspace(o,_,conf)
    if not conf.space then return end
    if o.line:sub(o.col-1,o.col-1)~=' ' then return end
    local fcol=o.line:reverse():find('[^ ]',#o.line-o.col+2)
    if not fcol then return end
    local newcol=#o.line-fcol+2
    local prev_pair=default.get_pairs_by_pos(o,newcol,'start',false,function(pair)
        return pair.conf.space
    end)[1]
    if not prev_pair then return end
    local index,rindex=prev_pair.fn.find_corresponding_pair(o,newcol-#prev_pair.start_pair)
    if not index then return end
    if rindex~=o.row then return end
    if o.line:sub(newcol,index-1):find('[^ ]') then
        if conf.space=='balance' then
            local left=#o.line:sub(newcol,index-1):match(' *')
            local right=#o.line:sub(newcol,index-1):reverse():match(' *')
            if left~=right then
                return utils.create_act({
                    {'h',left-right},
                    {'delete',0,left-right},
                    {'l',index-o.col-(right-left)},
                    {'delete',0,right-left},
                    {'h',index-o.col-(right-left)},
                })
            end
        end
        if o.line:sub(newcol,index-1):match(' *')
            >o.line:sub(newcol,index-1):reverse():match(' *') then return end
        return utils.create_act({
            {'h'},{'delete',0,1},
            {'l',index-o.col-1},
            {'delete',0,1},
            {'h',index-o.col-1},
        })
    end
    if conf.space=='balance' then
        local left=o.col-newcol
        local right=index-o.col
        if left~=right then
            return utils.create_act({
                {'h',left-right},
                {'delete',0,left-right},
                {'delete',0,right-left},
            })
        end
    end
    if o.line:sub(newcol,o.col-1)>o.line:sub(o.col,index-1) then return end
    return utils.create_act({{'h'},{'delete',0,2}})
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
    m[default.type_def]={'charins','space','dobackspace'}
    m.p=conf.p or mconf.p or 10
    m.doc='autopairs space key map'

    m.check=M.wrapp_space(m)
    m.filter=default.def_filter_wrapp(m)
    default.init_extensions(m,m.extensions)
    m.backspace=M.backspace
    m.get_map=default.def_map_get_map_wrapp(m)
    default.extend_map_check_with_map_check(m)
    return m
end
return M
