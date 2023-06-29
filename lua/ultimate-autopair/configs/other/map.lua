local M={}
function M.wrapp_get_map(m)
    return function (mode)
        if vim.tbl_contains(m.mode,mode) then
            return {m.lhs}
        end
    end
end
function M.wrapp_check(m)
    return function (o)
        if o.key~=m.lhs then return end
        if not m.rule() then return end
        if type(m.rhs)=='function' then
            return m.rhs(o,m)
        end
        return m.rhs
    end
end
function M.init_map(conf,mconf)
    local m={}
    m.p=conf.p or mconf.p or 10
    m.mode=type(conf[1])=='string' and {conf[1]} or conf[1]
    m.lhs=conf[2]
    m.rhs=conf[3]
    m.conf=conf
    m.rule=function () return true end
    m.get_map=M.wrapp_get_map(m)
    m.check=M.wrapp_check(m)
    return m
end
function M.init_conf(conf,mem)
    for _,v in ipairs(conf) do
        table.insert(mem,M.init_map(v,conf))
    end
end
return M
