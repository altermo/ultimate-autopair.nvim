local M={}
M.I={}
M.default_conf={
    map='<A-)>',
}
local default=require'ultimate-autopair.configs.default.utils'
local utils=require'ultimate-autopair.utils'
function M.I.tbl_find(tbl,pair_end)
    for k,v in ipairs(tbl) do
        if v.start_pair==pair_end.start_pair then
            return k
        end
    end
end
function M.get_open_start_pairs(line,col)
    local pair={}
    local i=1
    while i<=col do
        local pair_start=default.start_pair(i,line,true)
        local pair_end=default.end_pair(i,line)
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
    while i<=#line do
        local pair_start=default.start_pair(i,line,true)
        local pair_end=default.end_pair(i,line)
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
function M.get_pair_closes(line,col)
    local pair=M.get_open_start_pairs(line,col)
    return vim.fn.join(vim.tbl_map(function(x) return x.end_pair end,pair),'')
end
function M.close_pairs()
    local pair=M.get_pair_closes(
        utils.getline(),
        utils.getcol())
    return pair..utils.moveh(#pair)
end
function M.setup(conf)
    conf=vim.tbl_extend('force',M.default_conf,conf or {})
    if conf.map then
        vim.keymap.set('i',conf.map,M.close_pairs,{expr=true,replace_keycodes=false})
    end
end
return M
