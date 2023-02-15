return {
    call=function (o)
        if o.keyconf.ft then
            if not vim.tbl_contains(o.keyconf.ft,vim.o.filetype) then
                return 2
            end
        end
    end
}
