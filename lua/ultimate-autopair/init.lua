local prof=require'ultimate-autopair.prof_init'
local debug=require'ultimate-autopair.debug'
local default=require'ultimate-autopair.default'
local core=require'ultimate-autopair.core'
local M={}
M.configs={}
function M.toggle() core.disable=not core.disable end
function M.enable() core.disable=false end
function M.disable() core.disable=true end
function M.isenabled() return not core.disable end
function M.list()
    vim.ui.select(core.mem,{format_item=function (item)
        return (item.pair or (item.map and vim.inspect(item.map)) or ';;;;')
            ..' '..(item.doc or '')
    end},function (_,idx)
            vim.cmd.vnew()
            local buf=vim.api.nvim_create_buf(false,true)
            vim.api.nvim_set_option_value('bufhidden','wipe',{buf=buf})
            local win=vim.api.nvim_get_current_win()
            vim.api.nvim_win_set_buf(win,buf)
            vim.api.nvim_buf_set_lines(buf,0,-1,false,vim.split(vim.inspect(core.mem[idx]),'\n'))
        end)
end
---@param conf? prof.config
function M.setup(conf)
    M.configs={}
    if not M.skipversioncheck and vim.fn.has('nvim-0.9.0')~=1 then error('Requires at least version nvim-0.9.0') end
    table.insert(M.configs,M.extend_default(conf or {}))
    M.init()
end
---@param configs? prof.config[]
function M.init(configs)
    configs=configs or M.configs
    debug.run(core.clear,{})
    debug.run(prof.init,{info=configs,args={configs}})
    debug.run(core.init,{info=configs})
end
function M.clear()
    debug.run(core.clear,{})
end
---@param conf prof.config
---@return prof.config
function M.extend_default(conf)
    return vim.tbl_deep_extend('force',default.conf,conf or {})
end
return M
