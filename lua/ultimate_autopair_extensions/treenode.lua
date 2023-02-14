return{
    filter=function(o,conf)
        local parser=pcall(vim.treesitter.get_parser)
        if not parser then return end
        local err,node=pcall(vim.treesitter.get_node_at_pos,0,o.linenr-1,o.col-2,{})
        if not err then return end
        if vim.tbl_contains(conf.inside or {},node:type()) then
            local _,strbeg,_,strend=node:range()
            o.line=o.line:sub(strbeg+1,strend)
            o.col=o.col-strbeg
        end
    end}
