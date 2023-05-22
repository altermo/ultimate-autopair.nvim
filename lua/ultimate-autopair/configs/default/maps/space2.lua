local default=require 'ultimate-autopair.configs.default.utils'
local utils=require'ultimate-autopair.utils'
local M={}
function M.space(_)
    local col=utils.getcol()
    local line=utils.getline()
    local total=0
    local char
    local pcol
    for i=col-1,1,-1 do
        char=line:sub(i,i)
        if char~=' ' then
            pcol=i+1
            break
        end
        total=total+1
    end
    local prev_pair=default.get_pair(char)
    if not prev_pair or not prev_pair.conf.space then return end
    if prev_pair.rule and not prev_pair.rule() then return end
    if not default.get_type_opt(prev_pair,'start') then return end
    local matching_pair_pos=prev_pair.fn.find_end_pair(char,prev_pair.end_pair,line,pcol)
    if not matching_pair_pos then return end
    local ototal=#line:sub(col,matching_pair_pos-2):reverse():match(' *')
    if ototal>=total then return end
    return utils.movel(matching_pair_pos-col-1)..(' '):rep(total-ototal)..utils.moveh(total-ototal+matching_pair_pos-col-1)
end
function M.space_wrapp(m)
    return function()
        if not m.rule() then return end
        if not vim.regex(m.iconf.match or [[\a]]):match_str(vim.v.char) then return end
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(M.space(m) or '',true,true,true),'n',true)
    end
end
function M.init(conf,mconf,ext)
    if conf.enable==false then return end
    if mconf.map==false then return end
    local m={}
    m.rule=function () return true end
    m.iconf=conf
    m.conf=conf.conf or {}
    m._type={[default.type_pair]={'space2'}}
    m.extensions=ext
    m.p=conf.p or 10
    m.callback=M.space_wrapp(m)
    m.oinit=function (delete)
        if delete then vim.api.nvim_del_autocmd(M.au_id) return end
        m.au=vim.api.nvim_create_autocmd('InsertCharPre',{callback=m.callback})
    end
    default.init_extensions(m,m.extensions)
    m.check=nil
    m.doc='autopairs autocmd for space2'
    return m
end
return M
