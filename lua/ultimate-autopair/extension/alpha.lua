---FI
local M={}
local utils=require'ultimate-autopair.utils'
local default=require'ultimate-autopair.profile.default.utils'
M.alpha_re=[=[\v[[=a=][=b=][=c=][=d=][=e=][=f=][=g=][=h=][=i=][=j=][=k=][=l=][=m=][=n=][=o=][=p=][=q=][=r=][=s=][=t=][=u=][=v=][=w=][=x=][=y=][=z=][:keyword:]]]=]
---@param m prof.def.module|prof.def.m.pair
---@param incheck boolean?
---@return number
---@return number
function M.get_len(m,incheck)
    local offset=incheck and 1 or 0
    if m.pair then
        if default.get_type_opt(m,'start') then
            return #m.pair-offset,0
        elseif default.get_type_opt(m,'end') then
            return 0,#m.pair
        end
    end
    return 0,1-offset
end
---@param o core.o
---@param m prof.def.module
---@param ext prof.def.ext
---@param incheck boolean?
---@return boolean?
function M.check(o,m,ext,incheck)
    local lenb,lenf=M.get_len(m,incheck)
    if m.conf.alpha~=false and ext.conf.alpha or m.conf.alpha then
        ---@cast m prof.def.m.pair
        if not o.incmd and (m.pair=='"' or m.pair=="'") and utils.getsmartft(o)=='python' and not ext.conf.no_python then
            return
        end
        local alpha=m.conf.alpha or ext.conf.alpha
        alpha=type(alpha)=='string' and {alpha} or alpha
        if type(alpha)~='table' or vim.tbl_contains(alpha,utils.getsmartft(o)) then
            if vim.regex(M.alpha_re..'$'):match_str(o.line:sub(1,o.col-lenb-1)) then
                return true
            end
        end
    end
    if m.conf.alpha_after~=false and ext.conf.after or m.conf.alpha_after then
        local alpha=m.conf.alpha or ext.conf.alpha
        alpha=type(alpha)=='string' and {alpha} or alpha
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
    if not default.get_type_opt(m,'charins') then return end
    local check=m.check
    m.check=function(o)
        if M.check(o,m,ext,true) then return end
        return check(o)
    end
    if not ext.conf.filter then return end
    local filter=m.filter
    m.filter=function(o)
        if M.check(o,m,ext) then return end
        return filter(o)
    end
end
return M
