local default=require 'ultimate-autopair.profile.default.utils'
local core=require'ultimate-autopair.core'
local M={}
--TODO:
--- maybe create matchpair map which replaces builtin map %
---@param m core.module
---@return function
function M.wrapp_callback(m)
    ---@cast m table
    return function ()
        vim.api.nvim_buf_clear_namespace(0,m.ns,0,-1)
        if core.disable then return end
        ---@type prof.def.m.pair
        local pair
        local o=core.get_o_value('')
        for _,i in ipairs(default.filter_for_opt('pair')) do
            ---@cast i prof.def.m.pair
            if #i.start_pair==1 and #i.end_pair==1 and
                i.start_pair~=i.end_pair and
                o.line:sub(o.col,o.col)==i.pair and
                i.filter(o) then
                pair=i
                break
            end
        end
        if not pair then return end
        local col,row=pair.fn.find_corresponding_pair(o,o.col)
        if not col then return end
        vim.highlight.range(0,m.ns,'Visual',{o.row-1,o.col-1},{o.row-1,o.col})
        vim.highlight.range(0,m.ns,'Visual',{row-1,col-1},{row-1,col})
    end
end
---@return core.module
function M.init()
    local m={}
    m.doc='ultimate-autopair matchpair higlight'
    m.p=10
    m.ns=vim.api.nvim_create_namespace('ultimate-autopair-matchparen')
    m.oinit=function (delete)
        vim.api.nvim_buf_clear_namespace(0,m.ns,0,-1)
        if delete then return end
        vim.api.nvim_create_autocmd('CursorMoved',{callback=M.wrapp_callback(m),desc=m.doc,group='UltimateAutopair'})
    end
    return m
end
return M
