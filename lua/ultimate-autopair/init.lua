local config=require'ultimate-autopair.config'
local default=require'ultimate-autopair.default'
local M={}
function M.old_config_detector(conf)
    if conf.config_type~='default' then return end
    local function c(s,n)
        vim.notify('ultimate-autopair:\nOld configuration detected\nThe problem:\n'..s)
        return n
    end
    local cns=' option is no longer supported'
    local inb=', it uses a diffrent system now'

    if conf.extensions and vim.tbl_islist(conf.extensions) then
        return c('extensions option needs updating (aborting)',true)
    elseif conf._no_old_warn then
        return
    elseif conf.mapopt then
        return c('mapopt'..cns)
    elseif conf.fastend then
        return c('fastend'..cns)
    elseif conf.bs then
        if conf.bs.extensions then
            return c('bs.extensions'..cns..inb)
        elseif conf.bs.multichar then
            return c('bs.multichar'..cns..inb)
        end
    elseif conf.cr then
        if conf.cr.extensions then
            return c('cr.extensions'..cns..inb)
        elseif conf.cr.multichar then
            return c('cr.multichar'..cns..inb)
        end
    elseif conf.fastwarp then
        if conf.fastwarp.Wmap or conf.fastwarp.Wcmap then
            return c('fastwarp.Wmap & fastwarp.Wcmap'..cns)
        elseif conf.fastwarp.extensions then
            return c('fastwarp.extensions'..cns..inb)
        elseif conf.fastwarp.rextensions then
            return c('fastwarp.rextensions'..cns..inb)
        elseif conf.fastwarp.endextensions then
            return c('fastwarp.endextensions'..cns..inb)
        elseif conf.fastwarp.rendextensions then
            return c('fastwarp.rendextensions'..cns..inb)
        end
    elseif conf._default_beg_filter then
        return c('_default_beg_filter'..cns)
    elseif conf._default_end_filter then
        return c('_default_end_filter'..cns)
    elseif conf.ft then
        return c('ft'..cns..inb)
    end
    for _,v in ipairs{'bs','cr','space','fastwarp'} do
        if conf[v] and conf[v].fallback then
            return c(v..'.fallback'..cns)
        end
    end
end
function M.add_conf(conf)
    M.old_config_detector(conf)
    config.add_conf(conf)
end
function M.setup(conf)
    M.add_conf(vim.tbl_deep_extend('force',default.conf,conf or {}))
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
