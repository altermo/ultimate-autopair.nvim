local M={}
M.default_conf={
    map='<A-)>',
}
local default=require'ultimate-autopair.configs.default.utils'
local utils=require'ultimate-autopair.utils'
function M.get_open_start_pairs(line,col) --TODO: refactor
    local pair={}
    local i=1
    while i<=col do
        local pair_start=default.start_pair(i,line,true)
        local pair_end=default.end_pair(i,line)
        if pair_start then
            table.insert(pair,1,pair_start)
            i=i+#pair_start.pair
        elseif pair_end then
            for k,v in ipairs(pair) do
                if v.start_pair==pair_end.start_pair then
                    table.remove(pair,k)
                    break
                end
            end
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
            for k,v in ipairs(stack) do
                if v.start_pair==pair_end.start_pair then
                    table.remove(stack,k)
                    goto END
                end
            end
            for k,v in ipairs(pair) do
                if v.start_pair==pair_end.start_pair then
                    table.remove(pair,k)
                    goto END
                end
            end
            ::END::
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
        vim.keymap.set('i',conf.map,M.close_pairs,{expr=true})
    end
end
return M
