local M={}
local default=require'ultimate-autopair.configs.default.utils'
function M.check(o,m,ext)
    if ext.conf.alpha or m.conf.alpha then
        if o.key=='"' or o.key=="'" and vim.o.filetype=='python' and not ext.conf.no_python then
            if vim.regex([[\v\c<((r[fb])|([fb]r)|[frub])$]]):match_str(o.line:sub(o.col-3,o.col-1)) then
                return
            end
        end
        if vim.regex([[\a]]):match_str(o.line:sub(vim.str_utf_start(o.line,o.col-1)+o.col-1,o.col-1)) then
            return true
        end
    end
    if ext.conf.after or m.conf.alpha_after then  --TODO: test and fix
        if vim.regex([[\a]]):match_str(o.line:sub(o.col,vim.str_utf_end(o.line,o.col)+o.col)) then
            return true
        end
    end
end
function M.call(m,ext)
    if not default.get_type_opt(m,{'start','ambigous-start'}) then return end
    local check=m.check
    m.check=function (o)
        if M.check(o,m,ext) then return end
        return check(o)
    end
    if ext.conf.filter then --TODO: test
        local filter=m.filter
        m.filter=function(o)
            if M.check(o,m,ext) then return end
            return filter(o)
        end
    end
end
return M
