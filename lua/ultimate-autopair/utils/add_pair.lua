local utils=require'ultimate-autopair.utils.utils'
local open_pair=require'ultimate-autopair.utils.open_pair'
local M={}
function M.insert(pair,paire,line,col,type)
    if type==1 then
        utils.insert(pair:sub(-1,-1),line,col)
    elseif type==2 then
        utils.insert(pair:sub(-1,-1)..paire,line,col)
    elseif type==3 then
        utils.insert(paire:sub(-1,-1),line,col)
    end
    utils.movel()
end
function M.pairs(pair,other,line,col,wline,wcol)
    if open_pair.open_paire_after(pair,other,line,col) then
        return M.insert(pair,other,wline,wcol,1)
    end
    return M.insert(pair,other,wline,wcol,2)
end
function M.paira(pair,other,line,col,wline,wcol)
    local opab=open_pair.open_pair_ambigous_only_before(pair,line,col)
    local opaa=open_pair.open_pair_ambigous_only_after(pair,line,col)
    if opab ~= opaa then
        return M.insert(pair,other,wline,wcol,1)
    elseif opab and opaa then
        if line:sub(col,col)==pair then
            return M.insert(pair,other,wline,wcol,0)
        end
    end
    return M.insert(pair,other,wline,wcol,2)
end
function M.paire(pair,other,line,col,wline,wcol)
    if line:sub(col,col)==other then
        if col~=open_pair.open_paire_after(pair,other,line,col) then
            if not open_pair.open_pair_before(pair,other,line,col) then
                return M.insert(other,pair,wline,wcol,0)
            end
        end
    end
    return M.insert(pair,other,wline,wcol,3)
end
function M.pair(pair,paire,line,col,wline,wcol,type)
    if type==3 then
        M.paira(pair,paire,line,col,wline,wcol)
    elseif type==2 then
        M.paire(pair,paire,line,col,wline,wcol)
    elseif type==1 then
        M.pairs(pair,paire,line,col,wline,wcol)
    else
        return
    end
    return true
end
return M
