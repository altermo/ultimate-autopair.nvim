local default=require'ultimate-autopair.pair.default.utils.default'
local M={}
M.fn={}
function M.fn.newline_pair(o,m,conf)
    for _,v in ipairs(default.filter_pair_type()) do
        if v.newline then
            local ret=v.newline(o,m,conf)
            if ret then
                return ret
            end
        end
    end
end
function M.newline(o,m,conf)
    --TODO: implement a way to run only filtering extensions
    for _,v in pairs(M.fn) do
        local ret=v(o,m,conf)
        if ret then
            return ret
        end
    end
end
function M.do_newline()
    local core=require 'ultimate-autopair.core'
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(core.run('\r')(),true,true,true),'n',true)
end
function M.newline_wrapper(m,conf)
    return function (o)
        if o.key==(conf.map or '<cr>') then
            return M.newline(o,m,conf)
        end
    end
end
function M.init(conf,mem,_)
    if not conf.enable then return end
    local m={}
    m.check=M.newline_wrapper(m,conf)
    m.p=10
    function m.get_map(mode)
        if mode=='i' and not conf.nomap then
            return {conf.map or '<cr>'}
        end
    end
    table.insert(mem,m)
end
return M
