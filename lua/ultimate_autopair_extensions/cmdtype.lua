return {call=function (_,keyconf,conf)
    if vim.tbl_contains(conf.types,vim.fn.getcmdtype()) then
        return 2
    end
    if keyconf.cmdtype and vim.tbl_contains(keyconf.cmdtype,vim.fn.getcmdtype()) then
        return 2
    end
end}
