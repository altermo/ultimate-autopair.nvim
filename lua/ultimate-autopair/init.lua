local config=require'ultimate-autopair.config'
local debug=require'ultimate-autopair.debug'
local default=require'ultimate-autopair.default'
local core=require'ultimate-autopair.core'
local M={}
function M.toggle() core.disable=not core.disable end
function M.enable() core.disable=false end
function M.disable() core.disable=true end
function M._list()
    vim.ui.select(core.mem,{format_item=function (item)
        if item.pair then
            return item.pair..' '..(item.doc or '')
        end
        if item.map then
            return vim.inspect(item.map)..' '..(item.doc or '')
        end
    end},function (_,idx)
            vim.cmd.vnew()
            local buf=vim.api.nvim_create_buf(false,true)
            vim.api.nvim_set_option_value('bufhidden','wipe',{buf=buf})
            local win=vim.api.nvim_get_current_win()
            vim.api.nvim_win_set_buf(win,buf)
            vim.api.nvim_buf_set_lines(buf,0,0,false,vim.split(vim.inspect(core.mem[idx]),'\n'))
        end)
end
function M._old_config_detector(conf)
    if conf.config_type~='default' then return true end
    local function c(s)
        vim.notify('ultimate-autopair:\nOld configuration detected:\n'..s)
    end
    local cns=' option is no longer supported'
    local inb=', it uses a diffrent system now'

    if conf.extensions and vim.tbl_islist(conf.extensions) then return c('extensions option needs updating (aborting)') end
    if conf._no_old_warn then return true end
    if conf.mapopt then return c('mapopt'..cns) end
    if conf.fastend then return c('fastend'..cns) end
    if conf.bs then
        if conf.bs.extensions then return c('bs.extensions'..cns..inb) end
        if conf.bs.multichar then return c('bs.multichar'..cns..inb) end
        if conf.bs.nomap then return c('bs.nomap'..cns..inb) end
    end
    if conf.cr then
        if conf.cr.extensions then return c('cr.extensions'..cns..inb) end
        if conf.cr.multichar then return c('cr.multichar'..cns..inb) end
        if conf.cr.nomap then return c('cr.nomap'..cns..inb) end
    end
    if conf.fastwarp then
        if conf.fastwarp.Wmap or conf.fastwarp.Wcmap then return c('fastwarp.Wmap & fastwarp.Wcmap'..cns) end
        if conf.fastwarp.extensions then return c('fastwarp.extensions'..cns..inb) end
        if conf.fastwarp.rextensions then return c('fastwarp.rextensions'..cns..inb) end
        if conf.fastwarp.endextensions then return c('fastwarp.endextensions'..cns..inb) end
        if conf.fastwarp.rendextensions then return c('fastwarp.rendextensions'..cns..inb) end
    end
    if conf.space then
        if conf.space.nomap then return c('space.nomap'..cns..inb) end
    end
    if conf._default_beg_filter then return c('_default_beg_filter'..cns) end
    if conf._default_end_filter then return c('_default_end_filter'..cns) end
    if conf.ft then return c('ft'..cns..inb) end
    for _,v in ipairs{'bs','cr','space','fastwarp'} do
        if conf[v] and conf[v].fallback then
            return c(v..'.fallback'..cns)
        end
    end
    return true
end
function M.add_conf(conf)
    if not M._old_config_detector(conf) then return true end
    config.add_conf(conf)
end
function M.setup(conf)
    if M.add_conf(vim.tbl_deep_extend('force',default.conf,conf or {})) then return end
    M.init()
end
function M.init()
    debug.wrapp_smart_debugger(config.init,config.conf)()
end
function M.clear()
    debug.wrapp_smart_debugger(core.clear)()
end
return M
