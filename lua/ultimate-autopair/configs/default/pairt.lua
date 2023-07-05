local default=require'ultimate-autopair.configs.default.utils'
local utils=require'ultimate-autopair.utils'
local M={}
M.fn={
    in_pair=function (m,line,col,conf)
        if conf.notree then return end
        if utils.incmd() then return end
        local s,node=pcall(utils.gettsnode,conf.linenr-1,col-1) --Slow
        if not s or not node then return end
        if node:parent() and node:parent():type()==m.node then
            node=node:parent()
        end
        if node:type()~=m.node then return end
        local rs,start,_=node:start()
        if rs+1<conf.linenr then start=0 end
        if start+1==col then return end
        local re,end_,_=node:end_()
        if re+1>conf.linenr then end_=#line end
        return true,start+1,end_
    end,
}
function M.init(q)
    local m={}
    m.extensions=q.extensions
    m.conf=q.conf
    m[default.type_pair]={'pairo'}
    m.fn=default.init_fns(m,M.fn)
    m.mconf=q.mconf
    m.node=q.start_pair

    m.check=function () end
    m.rule=function () return true end
    default.init_extensions(m,m.extensions)
    m.check=nil
    m.p=q.p or 10
    m.doc=('autopairs treesitter node virtual pair: %s'):format(m.node)
    return m
end
return M
