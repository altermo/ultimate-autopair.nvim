---A
local default=require'ultimate-autopair.profile.default.utils'
local utils=require'ultimate-autopair.utils'
local M={}
---@param conf table
---@param o core.o
---@param m prof.def.m.pair
---@return string?
function M.check(conf,o,m)
    if o.line:sub(o.col,o.col-1+#m.pair)==m.pair then return end
    local next_char_index
    local i=o.col
    while i<=#o.line do
        local pair=default.end_pair(i,o,nil,function (p)
            return p.conf.fly
        end,conf.nofilter)
        if pair and pair.pair==m.pair then
            next_char_index=i
            break
        elseif vim.tbl_contains(conf.other_char,o.line:sub(i,i)) then
        elseif conf.only_jump_end_pair
            and default.start_pair(i,o,true,function (p)
                return p.conf.fly
            end,conf.nofilter) then
        else
            return
        end
        i=i+(pair and #pair.pair or 1)
    end
    if not next_char_index then return end
    if m.fn.check_end_pair(utils.set_o(o,{filter=conf.filter}),i) then
        --TODO: implement set_o
        M.save={o.line,o.col,next_char_index-o.col+#m.pair,m.pair}
        return utils.movel(next_char_index-o.col+#m.pair)
    end
end
---@param o core.o
---@return string?
function M.map_check(o)
    if M.save[1]~=o.line or M.save[2]~=(o.col-M.save[3]) then return end
    return utils.moveh(M.save[3])..M.save[4]
end
---@param ext prof.def.ext
---@param mconf prof.def.conf
---@return prof.def.m.map?
function M.init_map(ext,mconf)
    local conf=ext.conf.undoconf
    if not conf then return end
    local m={}
    m.map=mconf.map~=false and conf.map
    m.cmap=mconf.cmap~=false and (conf.cmap or (conf.cmap~=false and conf.map))
    m.conf=conf
    m.get_map=default.get_mode_map_wrapper(m.map,m.cmap)
    m.p=conf.p or mconf.p or 10
    m.filter=function (_) return true end
    m.check=function (o)
        if not default.key_check_cmd(o,m.map,m.cmap) then return end
        if not m.filter(o) then return end
        return M.map_check(o)
    end
    return m
end
---@param m prof.def.module
---@param ext prof.def.ext
function M.call(m,ext)
    if not default.get_type_opt(m,{'end'}) then return end
    local conf=ext.conf
    if not conf.fly then return end
    ---@cast m prof.def.m.pair
    local check=m.check
    m.check=function (o)
        local ret=M.check(conf,o,m)
        if ret then return ret end
        return check(o)
    end
end
return M
