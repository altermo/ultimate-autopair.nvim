local default=require 'ultimate-autopair.configs.default.utils'
local utils=require'ultimate-autopair.utils'
local M={}
function M.space(o,m)
    local conf=m.iconf
    local prev_char
    local pcol=o.col
    local total=0
    for i=o.col-1,1,-1 do
        prev_char=o.line:sub(i,i)
        if prev_char~=' ' then
            pcol=i+1
            break
        end
        total=total+1
    end
    local prev_pair=default.get_pair(prev_char)
    if not prev_pair or not prev_pair.conf.space then return end
    if not utils.incmd() and (vim.tbl_contains(conf.check_box_ft,vim.o.filetype) or conf.check_box_ft==true) and vim.regex([=[\v^\s*[+*-]|(\d+\.)\s+\[\]]=]):match_str(o.line:sub(1,o.col)) then return end
    if prev_pair.rule and not prev_pair.rule() then return end
    if not default.get_type_opt(prev_pair,'start') then return end
    local matching_pair_pos=prev_pair.fn.find_end_pair(prev_char,prev_pair.end_pair,o.line,pcol)
    if not matching_pair_pos then return end
    local ototal=#o.line:sub(o.col,matching_pair_pos-2):reverse():match(' *')
    if ototal>total then return end
    return ' '..utils.addafter(matching_pair_pos-o.col-1,(' '):rep(total-ototal+1))
end
function M.wrapp_space(m)
    return function (o)
        return M.space(o,m)
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
function M.init(conf,mconf,ext)
    if conf.enable==false then return end
    local m={}
    m.iconf=conf
    m.conf=conf.conf or {}
    m.map=mconf.map~=false and conf.map
    m.cmap=mconf.cmap~=false and conf.cmap
    m.p=conf.p or 10
    m.extensions=ext
    m._type={[default.type_pair]={'dobackspace','space'}}
    m.backspace=M.backspace
    m.check=M.wrapp_space(m)
    m.get_map=default.get_mode_map_wrapper(m.map,m.cmap)
    m.rule=function () return true end
    default.init_extensions(m,m.extensions)
    local check=m.check
    m.check=function (o)
        o.wline=o.line
        o.wcol=o.coll
        if not default.key_check_cmd(o,m.map,m.map,m.cmap,m.cmap) then return end
        if not m.rule() then return end
        return check(o)
    end
    return m
end
return M
