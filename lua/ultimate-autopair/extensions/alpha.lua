local M={}
local default=require'ultimate-autopair.configs.default.utils'
local utils=require'ultimate-autopair.utils'
function M.check(o,m,ext)
    if ext.conf.alpha or m.conf.alpha then
        if o.key=='"' or o.key=="'" and utils.getsmartft(o.linenr-1,o.col-1,o.save)=='python' and not ext.conf.no_python then
            if vim.regex([[\v\c<((r[fb])|([fb]r)|[frub])$]]):match_str(o.line:sub(o.col-1-#m.pair,o.col-#m.pair)) then
                return
            end
        end
        if vim.regex([[\a]]):match_str(o.line:sub(o.col-#m.pair,o.col-#m.pair)) then
            return true
        end
    end
    if ext.conf.after or m.conf.alpha_after then
        if vim.regex([[\a]]):match_str(o.line:sub(o.col,o.col)) then
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
    if ext.conf.filter then
        local filter=m.filter
        m.filter=function(o)
            if M.check(o,m,ext) then return end
            return filter(o)
        end
    end
end
return M
