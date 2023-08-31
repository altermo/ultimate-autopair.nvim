---FI
---@class ext.escape.conf:prof.def.ext.conf
---@field filter? boolean|fun(...:prof.def.optfn):boolean?
---@class ext.escape.pconf
---@field noescape? boolean|fun(...:prof.def.optfn):boolean?

local default=require'ultimate-autopair.profile.default.utils'
local M={}
---@param m prof.def.module
---@param o core.o
---@param incheck boolean?
---@return boolean?
function M.filter(m,o,incheck)
    ---@type ext.escape.pconf
    local pconf=m.conf
    if default.orof(pconf.noescape,o,m,incheck) then return end
    local col=o.col-1
    if incheck and default.get_type_opt(m,'start') then
        ---@cast m prof.def.m.pair
        col=o.col-#m.pair
    end
    local not_escape=true
    while o.line:sub(col,col)=='\\' do
        col=col-1
        not_escape=not not_escape
    end
    return not_escape
end
---@param m prof.def.module
---@param ext prof.def.ext
function M.call(m,ext)
    local conf=ext.conf
    ---@cast conf ext.escape.conf
    local check=m.check
    m.check=function(o)
        if M.filter(m,o,true) then
            return check(o)
        end
    end
    if type(conf.filter)~='function' and not conf.filter then return end
    local filter=m.filter
    m.filter=function(o)
        if type(conf.filter)=='function' and not conf.filter(o,m,false) then
            return filter(o)
        end
        if M.filter(m,o) then
            return filter(o)
        end
    end
end
return M
