return {
    call=function (o,_,mem)
        if o.cmdmode then return end
        for newkey,opt in pairs(mem) do
            local bool=#newkey>1 and opt.type~=2
            if bool and o.ext.filetype and opt.keyconf.ft then
                bool=vim.tbl_contains(opt.keyconf.ft,vim.o.filetype)
            end
            if bool and o.ext.rules and opt.keyconf.rules then
                local rules=require'ultimate-autopair.memory'.load_extension('rules')
                bool=rules.check_rules(opt.keyconf.rules,o)
            end
            if bool and o.ext.alpha and vim.tbl_contains(o.ext.alpha.before or {},newkey) then
                bool=not o.line:sub(o.col-#newkey,o.col-#newkey):match('%a')
            end
            if (bool
                and #newkey>1
                and newkey:sub(-1,-1)==o.key
                and o.line:sub(o.col-#newkey+1,o.col-1)==newkey:sub(1,-2)) then
                o.key=newkey
                o.pair=opt.pair
                o.paire=opt.paire
                o.type=opt.type
                return
            end
        end
    end
}
