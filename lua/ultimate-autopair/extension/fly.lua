---A
---@class ext.fly.conf:prof.def.ext.conf
---@field nofilter? boolean|fun(...:prof.def.optfn):boolean?
---@field only_jump_end_pair? boolean|fun(...:prof.def.optfn):boolean?
---@field other_char? string[]|fun(...:prof.def.optfn):string[]?
---@field undomapconf? prof.def.conf.map
---@field undomap? string
---@field undocmap? string
---@class ext.fly.pconf:prof.def.conf.pair
---@field fly? boolean|fun(...:prof.def.optfn):boolean?

local default=require'ultimate-autopair.profile.default.utils'
local utils=require'ultimate-autopair.utils'
local M={}
---@param conf ext.fly.conf
---@param o core.o
---@param m prof.def.m.pair
---@return string?
function M.check(conf,o,m)
    if m.fn.can_check_pre(o) then return end
    local next_char_index
    local i=o.col
    local cnofilter=default.orof(conf.nofilter,o,m,true)
    local cother_char=default.orof(conf.other_char,o,m,true)
    local conly_jump_end_pair=default.orof(conf.only_jump_end_pair,o,m,true)
    while i<=#o.line do
        local pair=default.get_pairs_by_pos(o,i,'end',true,function (p)
            return default.orof(p.conf.fly,o,m,true)
        end,cnofilter)[1]
        if pair and pair.pair==m.pair and (cnofilter or pair.fn.find_corresponding_pair(o,i)) then
            next_char_index=i
            break
        elseif pair and default.orof(pair.conf.fly,o,m,true) then
        elseif vim.tbl_contains(cother_char or {},o.line:sub(i,i)) then
        elseif not conly_jump_end_pair
            and #default.get_pairs_by_pos(o,i,'start',true,function (p)
                return default.orof(p.conf.fly,o,m,true)
            end,cnofilter)>0 then
        else
            return
        end
        i=i+(pair and #pair.pair or 1)
    end
    if not next_char_index then return end
    M.save={o.line,o.col,next_char_index-o.col+#m.pair,m.pair}
    return utils.create_act({{'l',next_char_index-o.col+#m.pair}})
end
---@param ext prof.def.ext
---@param mconf prof.def.conf
---@return prof.def.m.map[]
function M.init_module(ext,mconf)
    local m={}
    m.iconf=ext.conf --[[@as ext.fly.conf]]
    m.conf=m.iconf.undomapconf or {}
    m.map=mconf.map~=false and m.iconf.undomap
    m.cmap=mconf.cmap~=false and m.iconf.undocmap
    m.extensions=ext
    m[default.type_def]={}
    m.p=m.conf.p or mconf.p or 10
    m.doc='autopairs undo fly keymap'

    m.check=M.wrapp_undo(m)
    m.filter=default.def_filter_wrapp(m)
    default.init_extensions(m,m.extensions)
    m.get_map=default.def_map_get_map_wrapp(m)
    default.extend_map_check_with_map_check(m)
    return {m}
end
---@param _ prof.def.m.map
---@return core.check-fn
function M.wrapp_undo(_)
    return function (o)
        if M.save[1]~=o.line or M.save[2]~=(o.col-M.save[3]) then return end
        return utils.create_act({{'h',M.save[3]},M.save[4]})
    end
end
---@param m prof.def.module
---@param ext prof.def.ext
function M.call(m,ext)
    if not default.get_type_opt(m,{'end'}) then return end
    local conf=ext.conf
    ---@cast conf ext.fly.conf
    ---@type ext.fly.pconf
    local pconf=m.conf
    if type(pconf.fly)~='function' and not pconf.fly then return end
    ---@cast m prof.def.m.pair
    local check=m.check
    m.check=function (o)
        if type(pconf.fly)=='function' and not pconf.fly(o,m,false) then
            return check(o)
        end
        local ret=M.check(conf,o,m)
        if ret then return ret end
        return check(o)
    end
end
return M
