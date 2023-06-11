local default=require 'ultimate-autopair.configs.default.utils'
local utils=require'ultimate-autopair.utils'
local M={}
function M.space(o,m)
    local conf=m.iconf
    local pcol
    local total=0
    for i=o.col-1,1,-1 do
        if o.line:sub(i,i)~=' ' then
            pcol=i+1
            break
        end
        total=total+1
    end
    if not pcol then return end
    local prev_pair=default.start_pair(pcol,o.line)
    if not prev_pair or not prev_pair.conf.space then return end
    if not utils.incmd() and (conf.check_box_ft==true or vim.tbl_contains(conf.check_box_ft,vim.o.filetype)) and vim.regex([=[\v^\s*[+*-]|(\d+\.)\s+\[\]]=]):match_str(o.line:sub(1,o.col)) then return end
    if prev_pair.rule and not prev_pair.rule() then return end
    local matching_pair_pos=prev_pair.fn.find_end_pair(prev_pair,o.line,pcol)
    if not matching_pair_pos then return end
    local ototal=#o.line:sub(o.col,matching_pair_pos-#prev_pair.end_pair-1):reverse():match(' *')
    if ototal>total then return end
    return ' '..utils.addafter(matching_pair_pos-o.col-#prev_pair.end_pair,(' '):rep(total-ototal+1))
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
    for i=o.col-2,1,-1 do
        if o.line:sub(i,i)~=' ' then
            newcol=i+1
            break
        end
    end
    if not newcol then return end
    local prev_pair=default.start_pair(newcol,o.line)
    if not prev_pair then return end
    local matching_pair_pos=prev_pair.fn.find_end_pair(prev_pair,o.line,newcol)
    if not matching_pair_pos then return end
    if o.line:sub(newcol,matching_pair_pos-1-#prev_pair.end_pair):find('[^ ]') then
        if o.line:sub(newcol,o.col-1):find('[^ ]') then return end
        if conf.space=='balance' then
            local left=#o.line:sub(newcol,matching_pair_pos-1-#prev_pair.end_pair):match(' *')
            local right=#o.line:sub(newcol,matching_pair_pos-1-#prev_pair.end_pair):reverse():match(' *')
            if left~=right then
                return utils.moveh(left-right)..utils.delete(0,left-right)..utils.addafter(matching_pair_pos-o.col-(right-left)-#prev_pair.end_pair,utils.delete(0,right-left),0)
            end
        end
        if o.line:sub(newcol,matching_pair_pos-1-#prev_pair.end_pair):match(' *')
            >o.line:sub(newcol,matching_pair_pos-1-#prev_pair.end_pair):reverse():match(' *') then return end
        return utils.moveh()..utils.delete(0,1)..utils.addafter(matching_pair_pos-o.col-1-#prev_pair.end_pair,utils.delete(0,1),0)
    else
        if conf.space=='balance' then
            local left=o.col-newcol
            local right=matching_pair_pos-#prev_pair.end_pair-o.col
            if left~=right then
                return utils.moveh(left-right)..utils.delete(0,left-right)..utils.delete(0,right-left)
            end
        end
        if o.line:sub(newcol,o.col-1)>o.line:sub(o.col,matching_pair_pos-1-#prev_pair.end_pair) then return end
        return utils.moveh()..utils.delete(0,1)..utils.delete(0,1)
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
        o.wcol=o.col
        if not default.key_check_cmd(o,m.map,m.map,m.cmap,m.cmap) then return end
        if not m.rule() then return end
        return check(o)
    end
    m.doc='autopairs space key map'
    return m
end
return M
