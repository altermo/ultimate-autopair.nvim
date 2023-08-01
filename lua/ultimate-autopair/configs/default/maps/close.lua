local M={}
M.I={}
local default=require'ultimate-autopair.configs.default.utils'
local utils=require'ultimate-autopair.utils'
function M.I.tbl_find(tbl,pair_end)
    for k,v in ipairs(tbl) do
        if v.start_pair==pair_end.start_pair then
            return k
        end
    end
end
function M.get_open_start_pairs(o,col)
    local pair={}
    local i=1
    while i<=col do
        local pair_start=default.start_pair(i,o,true)
        local pair_end=default.end_pair(i,o)
        if pair_start then
            table.insert(pair,1,pair_start)
            i=i+#pair_start.pair
        elseif pair_end then
            local k=M.I.tbl_find(pair,pair_end)
            if k then table.remove(pair,k) end
            i=i+#pair_end.pair
        else
            i=i+1
        end
    end
    local stack={}
    i=col+1
    while i<=#o.line do
        local pair_start=default.start_pair(i,o,true)
        local pair_end=default.end_pair(i,o)
        if pair_start then
            table.insert(stack,1,pair_start)
            i=i+#pair_start.pair
        elseif pair_end then
            local k=M.I.tbl_find(stack,pair_end)
            if k then table.remove(stack,k)
            else
                local k2=M.I.tbl_find(pair,pair_end)
                if k2 then table.remove(pair,k2) end
            end
            i=i+#pair_end.pair
        else
            i=i+1
        end
    end
    return pair
end
function M.get_pair_closes(o,col)
    local pair=M.get_open_start_pairs(o,col)
    return vim.fn.join(vim.tbl_map(function(x) return x.end_pair end,pair),'')
end
function M.close_pairs(o,col)
    local pair=M.get_pair_closes(o,col)
    return pair..utils.moveh(#pair)
end
function M.wrapp_close(_)
    return function (o)
        return M.close_pairs(o,o.col)
    end
end
function M.wrapp_newline(_)
    return function(o,_,conf)
        if not conf.autoclose then return end
        local pairs=M.close_pairs(vim.tbl_extend('force',o,{line=o.line..(utils.getline(o.linenr+1) or '')}),#o.line) --TODO: is hack until multiline is implemented
        if pairs=='' then return end
        return utils.key_end..'\r'..pairs..utils.key_up..utils.key_home..utils.movel(o.col-1)..'\r'
    end
end
function M.init(conf,mconf,ext)
    if conf.enable==false then return end
    local m={}
    m.iconf=conf
    m.conf=conf.conf or {}
    m.map=mconf.map~=false and conf.map
    m.cmap=mconf.cmap~=false and conf.cmap
    m.p=conf.p or 10
    m.extensions=ext
    m[default.type_pair]={'close','donewline'}
    m.check=M.wrapp_close(m)
    m.get_map=default.get_mode_map_wrapper(m.map,m.cmap)
    m.rule=function () return true end
    m.filter=function () return m.rule() end
    m.newline=M.wrapp_newline(m)
    default.init_extensions(m,m.extensions)
    default.init_check_map(m)
    m.doc='autopairs close key map'
    return m
end
return M
