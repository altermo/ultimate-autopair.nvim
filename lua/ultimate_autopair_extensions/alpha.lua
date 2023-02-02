return {filter=function (o,conf)
    if o.type==2 or (o.line:sub(o.col,o.col)==o.paire and o.type==3) then
        return
    end
    if conf.before==true or vim.tbl_contains(conf.before or {},o.key) then
        if o.key=='"' or o.key=="'" and vim.o.filetype=='python' and not conf.no_python then
            if vim.fn.match(o.line:sub(o.col-3,o.col-1),[[\v<(r[fb])|([fb]r)|[frub]$]])~=-1 then
                return
            end
        end
        if o.line:sub(o.col-1,o.col-1):match('%a') then
            return 2
        end
    end
    if conf.after==true or vim.tbl_contains(conf.after or {},o.key) then
        if o.line:sub(o.col,o.col):match('%a') then
            return 2
        end
    end
end}
