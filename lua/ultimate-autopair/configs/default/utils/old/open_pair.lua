local u=require'ultimate-autopair.utils.info_line'
local M={}
function M.open_pair_only_before(pair,paire,line,col)
    return u.count_pair(pair,paire,line,1,col-1,true,1)
end
function M.open_paire_only_after(pair,paire,line,col)
    return u.count_paire(pair,paire,line,col,#line,true,1)
end
function M.open_pair_before(pair,paire,line,col)
    local count=u.count_pair(pair,paire,line,col,#line)
    return u.count_pair(pair,paire,line,1,col-1,true,count+1)
end
function M.open_paire_after(pair,paire,line,col)
    local count=u.count_paire(pair,paire,line,1,col-1)
    return u.count_paire(pair,paire,line,col,#line,true,count+1)
end
function M.open_pair_ambigous_only_before(pair,line,col)
    return u.count_ambigious_pair(pair,line,1,col-1)
end
function M.open_pair_ambigous_only_after(pair,line,col)
    return u.count_ambigious_pair(pair,line,col,#line)
end
function M.open_pair_ambigous_before_and_after(pair,line,col)
    return M.open_pair_ambigous_only_before(pair,line,col) and
        M.open_pair_ambigous_only_after(pair,line,col)
end
function M.open_pair_ambigous(pair,line,_)
    return u.count_ambigious_pair(pair,line,1,#line)
end
return M
