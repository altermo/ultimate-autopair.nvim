local open_pair=require'ultimate-autopair.utils.open_pair'
local utils=require'ultimate-autopair.utils.utils'
local M={}
function M.insert(pair,paire,type)
    if type==1 then
        return pair:sub(-1,-1)
    elseif type==2 then
        return pair:sub(-1,-1)..paire..utils.moveh(#paire)
    elseif type==3 then
        return paire:sub(-1,-1)
    elseif type==0 then
        return utils.movel(#paire)
    end
end
function M.pairs(pair,other,line,col)
    if open_pair.open_paire_after(pair,other,line,col) then
        return M.insert(pair,other,1)
    end
    return M.insert(pair,other,2)
end
function M.paira(pair,other,line,col)
    local opab=open_pair.open_pair_ambigous_only_before(pair,line,col)
    local opaa=open_pair.open_pair_ambigous_only_after(pair,line,col)
    if opab ~= opaa then
        return M.insert(pair,other,1)
    elseif opab and opaa then
        if line:sub(col,col)==pair then
            return M.insert(pair,other,0)
        end
    end
    return M.insert(pair,other,2)
end
function M.paire(pair,other,line,col)
    if line:sub(col,col)==other then
        if col~=open_pair.open_paire_after(pair,other,line,col) then
            if not open_pair.open_pair_before(pair,other,line,col) then
                return M.insert(pair,other,0)
            end
        end
    end
    return M.insert(pair,other,3)
end
function M.pair(pair,paire,line,col,type)
    if type==3 then
        return M.paira(pair,paire,line,col)
    elseif type==2 then
        return M.paire(pair,paire,line,col)
    elseif type==1 then
        return M.pairs(pair,paire,line,col)
    else
        return pair
    end
end
return M
