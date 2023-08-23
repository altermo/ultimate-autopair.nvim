---FI
---@class ext.alpha.pconf
---@field alpha? string
---@field alpha_char? string
---@field alpha_after? string
---@class ext.alpha.conf:prof.def.ext.conf
---@field alpha? string
---@field no_python? boolean
---@field after? string
---@field all? boolean
---@field filter? boolean

local M={}
local utils=require'ultimate-autopair.utils'
local default=require'ultimate-autopair.profile.default.utils'
M.alpha_re=[=[\v[[=a=][=b=][=c=][=d=][=e=][=f=][=g=][=h=][=i=][=j=][=k=][=l=][=m=][=n=][=o=][=p=][=q=][=r=][=s=][=t=][=u=][=v=][=w=][=x=][=y=][=z=][:keyword:]]]=]
---@param m prof.def.module|prof.def.m.pair
---@param incheck boolean?
---@return number
---@return number
function M.get_module_offset(m,incheck)
    if m.pair then
        if incheck and default.get_type_opt(m,'start') then
            return #m.pair-1,0
        end
        return 0,#m.pair
    end
    return 0,(incheck and 0 or 1)
end
---@param o core.o
---@param m prof.def.module
---@param ext prof.def.ext
---@param incheck boolean?
---@return boolean?
function M.check(o,m,ext,incheck)
    local lenb,lenf=M.get_module_offset(m,incheck)
    ---@type ext.alpha.pconf
    local pconf=m.conf
    local conf=ext.conf
    ---@cast conf ext.alpha.conf
    if pconf.alpha~=false and conf.alpha or pconf.alpha then
        ---@cast m prof.def.m.pair
        if not o.incmd and (m.pair=='"' or m.pair=="'") and utils.getsmartft(o)=='python' and not conf.no_python then
            return
        end
        local alpha=pconf.alpha or conf.alpha
        if type(alpha)~='table' or vim.tbl_contains(alpha,utils.getsmartft(o)) then
            if vim.regex(M.alpha_re..'$'):match_str(o.line:sub(1,o.col-lenb-1)) then
                return true
            end
        end
    end
    if pconf.alpha_after~=false and conf.after or pconf.alpha_after then
        local alpha=pconf.alpha_after or conf.after
        if type(alpha)~='table' or vim.tbl_contains(alpha,utils.getsmartft(o)) then
            if vim.regex(M.alpha_re):match_str(o.line:sub(o.col+lenf)) then
                return true
            end
        end
    end
end
---@param m prof.def.module
---@param ext prof.def.ext
function M.call(m,ext)
    local conf=ext.conf
    ---@cast conf ext.alpha.conf
    if not default.get_type_opt(m,conf.all and 'charins' or 'start') then return end
    local check=m.check
    m.check=function(o)
        if M.check(o,m,ext,true) then return end
        return check(o)
    end
    if not conf.filter then return end
    local filter=m.filter
    m.filter=function(o)
        if M.check(o,m,ext) then return end
        return filter(o)
    end
end
return M
