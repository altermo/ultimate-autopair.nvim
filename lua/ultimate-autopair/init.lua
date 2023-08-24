local prof=require'ultimate-autopair.prof_init'
local debug=require'ultimate-autopair.debug'
local default=require'ultimate-autopair.default'
local core=require'ultimate-autopair.core'
local M={}
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
function M._check_depreciated(conf)
    if not conf then return end
    local function rem(thing,alter,help)
        local msg=('ultimate-autopair: `%s` has ben removed, pleas use `%s` instead'):format(thing,alter)
        vim.notify(msg,vim.log.levels.WARN)
        if help then
            vim.notify(('For more information: %s'):format(help),vim.log.levels.WARN)
        end
    end
    if vim.tbl_get(conf,'extensions','rules') then
        rem(
            'extension.rules',
            'extension.cond',
            '`:h ultimate-autopair-ext-cond` or read the `Q&A.md`'
        )
        return true
    elseif vim.tbl_get(conf,'extensions','tsnode','outside') then

        rem(
            'extension.tsnode.outside',
            'extension.cond',
            '`:h ultimate-autopair-ext-cond`'
        )
        return true
    elseif vim.tbl_get(conf,'extensions','tsnode','inside') then

        rem(
            'extension.tsnode.inside',
            'extension.cond',
            '`:h ultimate-autopair-ext-cond`'
        )
        return true
    end
end
---@param conf? prof.config
function M.setup(conf)
    if not M.skipversioncheck and vim.fn.has('nvim-0.9.0')~=1 then error('Requires at least version nvim-0.9.0') end
    if M._check_depreciated(conf) then return end
    M.init({M.extend_default(conf or {})})
end
---@param configs? prof.config[]
function M.init(configs)
    debug.run(core.clear,{})
    debug.run(prof.init,{info=configs,args={configs,core.mem}})
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
