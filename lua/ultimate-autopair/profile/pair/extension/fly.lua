local M={}
---@param o ua.info
---@param conf table
---@return ua.actions?
function M.run(o,conf)
    local m=o.m --[[@as ua.prof.pair.pair]]
    local no=setmetatable({},{__index=o})
    while true do
        if no.line:sub(no.col,no.col+#m.end_pair)==m.end_pair then
            no.col=no.col+#m.end_pair --TODO: test for utf8 pair
            break
        elseif utils.in_list(conf.jump_other_char or {'}',')'},no.line:sub(no.col,no.col)) then
        else
            return
        end
        no.col=no.col+1 --TODO: pair might be more than one char
        if no.col>#no.line then
            if not conf.multiline then return end
            no.col=1
            no.row=no.row+1
        end
    end
    return {{'pos',no.col,no.row}}
end
M.ext_type={
    'after',
    'alternative', --If the normal action is done, don't ever do this one (especially hook.last_act_cycle)
}
M.conf={
    fly='boolean',
    multiline='boolean',
    jump_non_end_pair='boolean',
    jump_other_char='string[]',
}
M.type='end'
return M
