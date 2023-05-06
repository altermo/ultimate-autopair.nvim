local M={}
function M.filter_string(line,col,linenr,notree)
    if M.instring() then
    else
        if not notree then
            local parser=pcall(vim.treesitter.get_parser)
            if parser then

            end
        end
    end
end
return default.wrapp_old_extension(function(o,_,conf)
    return
    o.line,o.col=M.filter_string(o.line,o.col,o.linenr,(conf or {}).notree or o.cmdmode)
end,M)
