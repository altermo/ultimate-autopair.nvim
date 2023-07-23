local default=require'ultimate-autopair.configs.default.utils'
local M={}
function M.check(o,m,ext)
    if m.conf.noescape then return end
    if ext.conf.nochar or m.conf.nocharescape then return end
    local col=o.col-1
    local escape=false
    while o.line:sub(col,col)=='\\' do
        col=col-1
        escape=not escape
    end
    return escape
end
function M.filter(o,m,ext)
    if m.conf.noescape then return end
    if ext.conf.nofilter or m.conf.nofilterescape then return end
    local col=o.col-1
    local escape=false
    while o.line:sub(col,col)=='\\' do
        col=col-1
        escape=not escape
    end
    return escape
end
function M.call(m,ext)
    if not default.get_type_opt(m,'pair') then return end
    local check=m.check
    m.check=function (o)
        if M.check(o,m,ext) then return end
        return check(o)
    end
    local filter=m.filter
    m.filter=function (o)
        if M.filter(o,m,ext) then return end
        return filter(o)
    end
end
return M
