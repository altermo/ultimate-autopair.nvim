local default=require'ultimate-autopair.configs.default.utils.default'
local utils=require'ultimate-autopair.utils'
local M={}
M.fn={}
function M.fn.linefeed(o,m,conf)
    for _,v in ipairs(default.filter_pair_type({'pair','newline'})) do
        if v.newline then
            --TODO: check pair spesific rules
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
    local core=require'ultimate-autopair.core'
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(core.run('<cr>')(),true,true,true),'n',true)
end
function M.newline_wrapper(m,conf)
    return function (o)
        if default.key_eq_mode(o,conf.map) then
            return M.newline(o,m,conf)
        end
    end
end
function M.init(conf,mem,_)
    if not conf.enable then return end
    local m={}
    m.check=M.newline_wrapper(m,conf)
    m.p=10
    m.backspace=M.backspace
    function m.get_map(mode)
        if mode=='i' and conf.map then
            return {conf.map}
        end
    end
    table.insert(mem,m)
    table.insert(mem,{p=0,check=function (o)
        if o.key=='<cr>' then
            return '\r'
        end
    end,get_map=m.get_map})
end
return M
