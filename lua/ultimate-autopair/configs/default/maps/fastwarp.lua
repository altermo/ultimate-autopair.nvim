--TODO: implement extensions for fastwarp
local default=require 'ultimate-autopair.configs.default.utils'
local utils=require'ultimate-autopair.utils'
local M={}
M.ext={}
function M.ext.fastwarp_over_pair(o,ind,p)
    if o.col+1~=ind then return end
    local pair=default.get_pair(o.line:sub(ind,ind))
    --TODO: check pair.rule()
    if not pair then return end
    if not default.get_type_opt(pair,'start') then return end
    local matching_pair_pos=pair.fn.find_end_pair(pair.start_pair,pair.end_pair,o.line,ind+1)
    if not matching_pair_pos then return end
    return utils.delete(0,1)..utils.movel(matching_pair_pos-o.col)..p..utils.moveh(),matching_pair_pos-1
end
function M.ext.fastwarp_next_to_pair(o,ind,p)
    if o.col+1==ind then return end
    local pair=default.get_pair(o.line:sub(ind,ind))
    --TODO: check pair.rule()
    if not pair then return end
    if not default.get_type_opt(pair,'start') then return end
    return utils.delete(0,1)..utils.movel(ind-o.col-1)..p..utils.moveh(),ind-2
end
function M.ext.fastwarp_over_word(o,ind,p)
    local regex=vim.regex([[\w]])
    if not regex:match_str(o.line:sub(ind,ind)) then return end
    while regex:match_str(o.line:sub(ind,ind)) do
      ind=ind+1
    end
    return utils.delete(0,1)..utils.movel(ind-o.col-1)..p..utils.moveh(),ind-2
end
function M.fastwarp(o,_)
    --TODO: run filtering extensions
    local p=o.line:sub(o.col,o.col)
    local pair=default.get_pair(p)
    if not pair then return end
    if not default.get_type_opt(pair,'end') then return end
    --TODO: check pair.rule()
    for i=o.col,#o.line do
        local ind=i
        for _,v in pairs(M.ext) do
            local ret=v(o,ind,p)
            if ret then return ret end
        end
    end
end
function M.wrapp_fastwarp(m)
    return function (o)
        if default.key_check_cmd(o,m.map,m.map,m.cmap,m.cmap) then
            return M.fastwarp(o,m)
        end
    end
end
function M.init(conf,mconf)
    if not conf.enable then return end
    local m={}
    m.conf=conf
    m.map=mconf.map~=false and conf.map
    m.cmap=mconf.cmap~=false and conf.cmap
    m.p=conf.p or 10
    m.check=M.wrapp_fastwarp(m)
    m.get_map=default.get_mode_map_wrapper(m.map,m.cmap)
    return m
end
return M
