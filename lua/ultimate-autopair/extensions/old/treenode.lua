local utils=require'ultimate-autopair.utils.utils'
return{
    call=function(o,conf)
        local parser=pcall(vim.treesitter.get_parser)
        if not parser then return end
        local tserr,tsnode=pcall(utils.gettsnode,o.linenr-1,o.col-2)
        if tserr and tsnode and vim.tbl_contains(conf.inside or {},tsnode:type()) then
            local _,strbeg,_,strend=tsnode:range()
            o.line=o.line:sub(strbeg+1,strend)
            o.col=o.col-strbeg
            return
        end
        if conf.outside then
            local newline=''
            for i=1,#o.line do
                local err,node=pcall(utils.gettsnode,o.linenr-1,i-1)
                if err and vim.tbl_contains(conf.outside,node:type()) then
                    newline=newline..'\1'
                else
                    newline=newline..o.line:sub(i,i)
                end
            end
            o.line=newline
        end
    end}
