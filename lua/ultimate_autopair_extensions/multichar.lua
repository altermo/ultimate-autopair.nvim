return {
    filter=function (o,_,_,gmem)
        if o.cmdmode then return end
        for newkey,opt in pairs(gmem) do
            local bool=#newkey>1 and opt.type~=2
            if bool and opt.ext.filetype and vim.tbl_count(opt.ext.filetype)~=0 then
                bool=opt.ext.filetype[vim.o.filetype]
            end
            if bool and opt.ext.rules and vim.tbl_count(opt.ext.rules)~=0 then
                local rules=require'ultimate-autopair.memory'.load_extension('rules')
                bool=rules.check_rules(opt.ext.rules,o)
            end
            if bool and opt.ext.alpha and vim.tbl_contains(opt.ext.alpha.before or {},newkey) then
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
