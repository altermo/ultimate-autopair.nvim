---FI
---@class ext.alpha.pconf
---@field alpha? string[]|boolean|fun(...:prof.def.optfn):string[]|boolean?
---@field alpha_after? string[]|boolean|fun(...:prof.def.optfn):string[]|boolean?
---@class ext.alpha.conf:prof.def.ext.conf
---@field alpha? string[]|boolean|fun(...:prof.def.optfn):string[]|boolean?
---@field no_python? boolean|fun(...:prof.def.optfn):boolean?
---@field after? string[]|boolean|fun(...:prof.def.optfn):string[]|boolean?
---@field all? boolean|fun(...:prof.def.optfn):boolean?
---@field filter? boolean|fun(...:prof.def.optfn):boolean?
---@field no_ft_iskeyword? boolean|fun(...:prof.def.optfn):boolean?

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
    local pcalpha=default.orof(pconf.alpha,o,m,incheck)
    local calpha=default.orof(conf.alpha,o,m,incheck)
    local cno_python=default.orof(conf.no_python,o,m,incheck)
    if pcalpha~=false and calpha or pcalpha then
        ---@cast m prof.def.m.pair
        if not o.incmd and (m.pair=='"' or m.pair=="'") and utils.getsmartft(o)=='python' and not cno_python then
            if vim.regex([[\v\c<((r[fb])|([fb]r)|[frub])$]]):match_str(o.line:sub(1,o.col-lenb-1)) then
                return
            end
        end
        local alpha=pcalpha or calpha
        if type(alpha)~='table' or vim.tbl_contains(alpha,utils.getsmartft(o)) then
            if vim.regex(M.alpha_re..'$'):match_str(o.line:sub(1,o.col-lenb-1)) then
                return true
            end
        end
    end
    local pcalpha_after=default.orof(pconf.alpha_after,o,m,incheck)
    local cafter=default.orof(conf.after,o,m,incheck)
    if pcalpha_after~=false and cafter or pcalpha_after then
        local alpha=pcalpha_after or cafter
        if type(alpha)~='table' or vim.tbl_contains(alpha,utils.getsmartft(o)) then
            if vim.regex(M.alpha_re):match_str(o.line:sub(o.col+lenf)) then
                return true
            end
        end
    end
end
---@param o core.o
---@param m prof.def.module
---@param ext prof.def.ext
---@param incheck boolean?
---@return boolean?
function M.check_change_iskeyword(o,m,ext,incheck)
    local conf=ext.conf
    ---@cast conf ext.alpha.conf
    local savekeyword=vim.o.iskeyword
    if default.orof(conf.no_ft_iskeyword,o,m,incheck) then
        vim.o.iskeyword=vim.api.nvim_get_option_value('iskeyword',{buf=vim.api.nvim_get_current_buf()})
    else
        vim.o.iskeyword=vim.filetype.get_option(utils.getsmartft(o),'iskeyword')
    end
    local ret=M.check(o,m,ext,incheck)
    vim.o.iskeyword=savekeyword
    return ret
end
---@param m prof.def.module
---@param ext prof.def.ext
function M.call(m,ext)
    local conf=ext.conf
    ---@cast conf ext.alpha.conf
    if not default.get_type_opt(m,conf.all and 'charins' or 'start') then return end
    local check=m.check
    m.check=function(o)
        if M.check_change_iskeyword(o,m,ext,true) then return end
        return check(o)
    end
    if type(conf.filter)~='function' and not conf.filter then return end
    local filter=m.filter
    m.filter=function(o)
        if type(conf.filter)=='function' and not conf.filter(o,m,false) then
            return filter(o)
        end
        if M.check_change_iskeyword(o,m,ext) then return end
        return filter(o)
    end
end
return M
