--TODO: implement extensions for space
local default=require 'ultimate-autopair.configs.default.utils'
local utils=require'ultimate-autopair.utils'
local M={}
function M.space(o,m)
    local conf=m.conf
    local prev_char
    local pcol=o.col
    --TODO: run filtering extensions
    for i=o.col-1,1,-1 do
        prev_char=o.line:sub(i,i)
        if prev_char~=' ' then
            pcol=i+1
            break
        end
    end
    local prev_pair=default.get_pair(prev_char)
    if not utils.incmd() and (vim.tbl_contains(conf.check_box_ft,vim.o.filetype) or conf.check_box_ft==true) and vim.regex([=[\v^\s*[+*-]|(\d+\.)\s+\[\]]=]):match_str(o.line:sub(1,o.col)) then
    elseif prev_pair and prev_pair.conf.space and prev_char and
        --TODO: check prev_pair.rule()
        (default.get_type_opt(prev_pair,'ambiguous') or default.get_type_opt(prev_pair,'start')) then
        local matching_pair_pos=prev_pair.fn.find_end_pair(prev_char,prev_pair.end_pair,o.line,pcol)
        if matching_pair_pos then
            return ' '..utils.addafter(matching_pair_pos-o.col-1,' ')
        end
    end
end
function M.wrapp_space(m)
    return function (o)
        if default.key_check_cmd(o,m.map,m.map,m.cmap,m.cmap) then
            return M.space(o,m)
        end
    end
end
function M.init(conf,mconf)
    if not conf.enable then return end
    local m={}
    m.conf=conf
    m.map=mconf.map and conf.map
    m.cmap=mconf.cmap and conf.cmap
    m.p=conf.p or 10
    m.check=M.wrapp_space(m)
    m.get_map=default.get_mode_map_wrapper(m.map,m.cmap)
    return m
end
return M
