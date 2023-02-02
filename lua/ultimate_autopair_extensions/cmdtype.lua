return {filter=function (_,conf)
    if vim.tbl_contains(conf,vim.fn.getcmdtype()) then
        return 2
    end
end}
