local config=require'ultimate-autopair.config'
local default=require'ultimate-autopair.default'
local M={}
function M.add_conf(conf)
    config.add_conf(conf)
end
function M.setup(conf)
    M.add_conf(vim.tbl_deep_extend('force',default.conf,conf or {}))
    --M.add_conf({
    --config_init='default',
    --map=true,
    --cmap=true,
    --pair_map=true,
    --pair_cmap=true,
    --extensions={
    --alpha={p=30},
    --},
    --{"'","'",alpha=true},
    --{'(',')'},
    --}) --TODO: Temporary hack
    M.init()
end
function M.init()
    config.init()
end
function M._list()
    local core=require'ultimate-autopair.core'
    vim.ui.select(core.mem,{format_item=function (item)
        if item.pair then
            return item.pair
        end
    end},function (_,idx)
            vim.cmd.vnew()
            local buf=vim.api.nvim_create_buf(false,true)
            vim.api.nvim_buf_set_option(buf,'bufhidden','wipe')
            local win=vim.api.nvim_get_current_win()
            vim.api.nvim_win_set_buf(win,buf)
            vim.api.nvim_buf_set_lines(buf,0,0,false,vim.split(vim.inspect(core.mem[idx]),'\n'))
        end)
end
return M
