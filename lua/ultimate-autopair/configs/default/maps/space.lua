local default=require'ultimate-autopair.configs.default.utils.default'
local utils=require'ultimate-autopair.utils'
local M={}
function M.space(o,m,conf)
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
    if not utils.incmd() and vim.tbl_contains(conf.check_box_ft,vim.o.filetype) and vim.regex([=[\v^\s*[+*-]|(\d+\.)\s+\[\]]=]):match_str(o.line:sub(1,o.col)) then
    --elseif conf.notinstr and in_string(o.line,o.col,utils.getlinenr(),conf.notree) then
    elseif prev_pair and prev_pair.type==1 then
        local matching_pair_pos=info_line.findepaire(o.line,pcol,prev_char,prev_pair.paire)
        if matching_pair_pos then
            return ' '..utils.addafter(matching_pair_pos-o.col,' ')
        end
    end
end
function M.space_wrapper(m,conf)
    return function (o)
        if o.key==(conf.map or ' ') then
            return M.space(o,m,conf)
        end
    end
end
function M.init(conf,mem,mconf)
    if not conf.enable then return end
    local m={}
    m.check=M.space_wrapper(m,conf)
    m.p=10
    function m.get_map(mode)
        if mode=='i' and not conf.nomap then
            return {conf.map or ' '}
        elseif mode=='c' and (conf.nocmap or mconf.cmap) then
            return {conf.cmap or ' '}
        end
    end
    table.insert(mem,m)
    table.insert(mem,{p=0,check=function (o)
        if o.key==(' ') then
            return ' '
        end
    end,get_map=m.get_map})
end
return M
