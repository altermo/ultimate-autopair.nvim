--TODO: implement extensions for space
local default=require 'ultimate-autopair.configs.default.utils'
local utils=require'ultimate-autopair.utils'
local M={}
function M.space(o,m)
    --TODO: run filtering extensions
    local conf=m.conf
    local prev_char
    local pcol=o.col
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
        default.get_type_opt(prev_pair,{'ambiguous','start'}) then
        --TODO: check prev_pair.rule()
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
function M.backspace(o,_,conf)
    if not conf.space then return end
    if o.line:sub(o.col-1,o.col-1)~=' ' then return end
    local newcol
    local char
    for i=o.col-2,1,-1 do
        char=o.line:sub(i,i)
        if char~=' ' then
            newcol=i+2
            break
        end
    end
    local prev_n_pair=default.get_pair(char)
    if not prev_n_pair or not default.get_type_opt(prev_n_pair,'start') then return end
    local matching_pair_pos=prev_n_pair.fn.find_end_pair(char,prev_n_pair.end_pair,o.line,newcol-1)
    if not matching_pair_pos then return end
    if o.line:sub(newcol-1,matching_pair_pos-2):find('[^ ]') then
        if o.line:sub(newcol-1,o.col-1):find('[^ ]') then return end
        if o.line:sub(newcol-1,matching_pair_pos-2):match(' *')
            >o.line:sub(newcol-1,matching_pair_pos-2):reverse():match(' *') then return end
        return utils.moveh()..utils.delete(0,1)..utils.movel(matching_pair_pos-o.col-2)..utils.delete(0,1)..utils.moveh(matching_pair_pos-o.col-2)
    else
        if o.line:sub(newcol-1,o.col-1)>o.line:sub(o.col,matching_pair_pos-2) then return end
        return utils.moveh()..utils.delete(0,1)..utils.movel(matching_pair_pos-o.col-2)..utils.delete(0,1)..utils.moveh(matching_pair_pos-o.col-2)
    end
end
function M.init(conf,mconf)
    if not conf.enable then return end
    local m={}
    m.conf=conf
    m.map=mconf.map~=false and conf.map
    m.cmap=mconf.cmap~=false and conf.cmap
    m.p=conf.p or 10
    m._type={[default.type_pair]={'dobackspace'}}
    m.rule=function () return true end
    m.backspace=M.backspace
    m.check=M.wrapp_space(m)
    m.get_map=default.get_mode_map_wrapper(m.map,m.cmap)
    return m
end
return M
