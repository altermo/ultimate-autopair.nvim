local default=require'ultimate-autopair.configs.default.utils'
local utils=require'ultimate-autopair.utils'
local M={}
M.fn={
    in_pair=function (m,line,col,conf)
        if conf.notree then return end
        if utils.incmd() then return end
        if line:sub(col,col)=='\1' then return end
        if not pcall(vim.treesitter.get_parser) then return end
        local s,node=pcall(utils.gettsnode,conf.linenr-1,col-1)
        local ns,nnode=pcall(utils.gettsnode,conf.linenr-1,col-2)
        if not s or not node then return end
        if not ns or not nnode then return end
        local rs,start,_=node:start()
        if rs+1<conf.linenr then start=0 end
        local re,end_,_=node:end_()
        if re+1>conf.linenr then end_=#line end
        return node:type()==m.node and nnode==node,start+1,end_
    end
}
function M.init(q)
    local m={}
    m.extensions=q.extensions
    m.conf=q.conf
    m._type={[default.type_pair]={'pairo'}}
    m.fn=M.fn
    m.node=q.start_pair

    m.check=function () end
    m.rule=function () return true end
    default.init_extensions(m,m.extensions)
    m.p=q.p or 10
    m.doc=('autopairs treesitter node virtual pair: %s'):format(m.node)
    return m
end
return M
