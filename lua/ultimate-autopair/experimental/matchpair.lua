local default=require 'ultimate-autopair.profile.default.utils'
local core=require'ultimate-autopair.core'
local utils=require'ultimate-autopair.utils'
local M={}
---Instruction: if you want TO USE THIS
--use
---require'ultimate-autopair.core'.modes={'i','c','n'}
---require'ultimate-autopair'.init({your_pair_config,{
---  profile='raw',
---  require'ultimate-autopair.experimental.matchpair'.init(),
---  require'ultimate-autopair.experimental.matchpair'.init_map(),
---}})
---@param m core.module
---@return function
function M.wrapp_highlight_callback(m)
    ---@cast m table
    return function ()
        vim.api.nvim_buf_clear_namespace(0,m.ns,0,-1)
        if core.disable then return end
        local o=core.get_o_value('')
        local row,col=M.find_corresponding_pair_under_curosr(o)
        if not row then return end
        vim.highlight.range(0,m.ns,'Visual',{o.row-1,o.col-1},{o.row-1,o.col})
        vim.highlight.range(0,m.ns,'Visual',{row-1,col-1},{row-1,col})
    end
end
---@param o core.o
---@return number?
---@return number?
function M.find_corresponding_pair_under_curosr(o)
    local pair,col,row=default.get_pair_and_end_pair_pos_from_start(o,o.col,nil,function (p)
        return #p.start_pair==1 and #p.end_pair==1
    end)
    if not pair then
        pair,col,row=default.get_pair_and_start_pair_pos_from_end(o,o.col,nil,function (p)
            return #p.start_pair==1 and #p.end_pair==1
        end)
    end
    if not pair then return end
    return row,col
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
        vim.api.nvim_create_autocmd('CursorMoved',{callback=M.wrapp_highlight_callback(m),desc=m.doc,group='UltimateAutopair'})
    end
    return m
end
---@return core.module
function M.init_map()
    local m={}
    m.doc='ultimate-autopair matchpair map'
    m.p=10
    m.check=function (o)
        if o.mode=='n' and o.key=='%' then
            local row,col=M.find_corresponding_pair_under_curosr(o)
            if not row or not col then return '' end
            return (row<o.row and ('k'):rep(o.row-row) or ('j'):rep(row-o.row))..'0'..('l'):rep(col-1)
        end
    end
    m.get_map=function (mode) if mode=='n' then return {'%'} end end
    return m
end
return M