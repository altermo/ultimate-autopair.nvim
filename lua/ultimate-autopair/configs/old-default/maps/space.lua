local default=require'ultimate-autopair.configs.default.utils.default'
local utils=require'ultimate-autopair.utils'
local mutils=require'ultimate-autopair.configs.default.maps.utils'
local M={}
function M.space(o,_,conf)
    --TODO: implement a way to run only filtering extensions
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
        (default.get_type_opt(prev_pair,'ambiguous') or default.get_type_opt(prev_pair,'start')) then
        local matching_pair_pos=prev_pair.fn.find_end_pair(prev_char,prev_pair.end_pair,o.line,pcol)
        if matching_pair_pos then
            return ' '..utils.addafter(matching_pair_pos-o.col-1,' ')
        end
    end
end
function M.space_wrapper(m,conf)
    return function (o)
        if default.key_eq_mode(o,conf.map,conf.cmap) then
            return M.space(o,m,conf)
        end
    end
end
function M.backspace(o,_,conf)
    if conf.space and o.line:sub(o.col-1,o.col-1)==' ' then
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
        if prev_n_pair and default.get_type_opt(prev_n_pair,'start') then
            local matching_pair_pos=prev_n_pair.fn.find_end_pair(char,prev_n_pair.end_pair,o.line,newcol-1)
            if not matching_pair_pos then return end
            if o.line:sub(newcol-1,matching_pair_pos-2):find('[^ ]') then
                if o.line:sub(newcol-1,o.col-1):find('[^ ]') then return end
                if o.line:sub(newcol-1,matching_pair_pos-2):match(' *')
                    <=o.line:sub(newcol-1,matching_pair_pos-2):reverse():match(' *') then
                    return utils.moveh()..utils.delete(0,1)..utils.movel(matching_pair_pos-o.col-2)..utils.delete(0,1)..utils.moveh(matching_pair_pos-o.col-2)
                else
                    return utils.moveh()..utils.delete(0,1)
                end
            else
                if o.line:sub(newcol-1,o.col-1)<=o.line:sub(o.col,matching_pair_pos-2) then
                    return utils.moveh()..utils.delete(0,1)..utils.movel(matching_pair_pos-o.col-2)..utils.delete(0,1)..utils.moveh(matching_pair_pos-o.col-2)
                else
                    return utils.moveh()..utils.delete(0,1)
                end
            end
        end
    end
end
function M.init(conf,mem,_)
    if not conf.enable then return end
    local m={}
    m.check=M.space_wrapper(m,conf)
    m.p=10
    m._type={[default.type_pair]={'backspace'}}
    m.backspace=M.backspace
    m.get_map=mutils.get_map_wrapper(conf)
    table.insert(mem,m)
    table.insert(mem,{p=0,check=function (o)
        if o.key==(' ') then
            return ' '
        end
    end,get_map=m.get_map})
end
return M
