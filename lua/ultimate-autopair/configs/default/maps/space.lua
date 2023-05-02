local M={}
function M.init(conf,mem,_)
    if not conf.enable then return end
    local m={}
    m.p=conf.p or 10
    table.insert(mem,m)
end
return M
