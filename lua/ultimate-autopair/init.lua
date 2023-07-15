local config=require'ultimate-autopair.config'
local debug=require'ultimate-autopair.debug'
local default=require'ultimate-autopair.default'
local core=require'ultimate-autopair.core'
local M={}
function M.toggle() core.disable=not core.disable end
function M.enable() core.disable=false end
function M.disable() core.disable=true end
function M.list()
    vim.ui.select(core.mem,{format_item=function (item)
        if item.pair then
            return item.pair..' '..(item.doc or '')
        end
        if item.map then
            return vim.inspect(item.map)..' '..(item.doc or '')
        end
        return ';;;; '..(item.doc or '')
    end},function (_,idx)
            vim.cmd.vnew()
            local buf=vim.api.nvim_create_buf(false,true)
            vim.api.nvim_set_option_value('bufhidden','wipe',{buf=buf})
            local win=vim.api.nvim_get_current_win()
            vim.api.nvim_win_set_buf(win,buf)
            vim.api.nvim_buf_set_lines(buf,0,0,false,vim.split(vim.inspect(core.mem[idx]),'\n'))
        end)
end
function M.add_conf(conf)
    config.add_conf(conf)
end
function M.setup(conf)
    M.add_conf(vim.tbl_deep_extend('force',default.conf,conf or {}))
    M.init()
end
function M.init()
    debug.wrapp_smart_debugger(config.init,config.conf)()
end
function M.clear()
    debug.wrapp_smart_debugger(core.clear)()
end
return M
