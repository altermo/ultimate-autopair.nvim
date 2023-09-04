local M={}
function M.create_action()
    local m={}
    m.doc='ultimate-autopair fix nvim-treesitter-endwise'
    m.p=100
    m.check=function (o)
        if o.mode~='i' or o.key~='\r' then return end
        M.linecount=vim.api.nvim_buf_line_count(0)
    end
    m.oinit=function (delete)
        if delete then return end
        vim.api.nvim_create_autocmd('User',{pattern='PreNvimTreesitterEndwiseCR',callback=function()
            if not M.linecount then return end
            if M.linecount+1==vim.api.nvim_buf_line_count(0) then M.linecount=nil
            else M.linecount=vim.api.nvim_buf_line_count(0) end
        end,group='UltimateAutopair',desc=M.doc})
        vim.api.nvim_create_autocmd('User',{pattern='PostNvimTreesitterEndwiseCR',callback=function()
            if not M.linecount then return end
            if M.linecount~=vim.api.nvim_buf_line_count(0) then
                vim.cmd.norm{bang=true,'jJk'}
            end
            M.linecount=nil
        end,group='UltimateAutopair',desc=M.doc})
    end
    m.get_map=function (mode) if mode=='i' then return {'\r'} end end
    return m
end
---@param _ prof.cond.conf
---@param mem core.module[]
function M.init(_,mem)
    table.insert(mem,M.create_action())
end
return M
