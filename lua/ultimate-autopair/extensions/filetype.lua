return {
    call=function (_,keyconf,conf)
        if conf.ft and not vim.tbl_contains(conf.ft,vim.o.filetype) then
            return 2
        end
        if conf.nft and vim.tbl_contains(conf.nft,vim.o.filetype) then
            return 2
        end
        if keyconf.ft and not vim.tbl_contains(keyconf.ft,vim.o.filetype) then
            return 2
        end
        if keyconf.nft and vim.tbl_contains(keyconf.nft,vim.o.filetype) then
            return 2
        end
    end
}
