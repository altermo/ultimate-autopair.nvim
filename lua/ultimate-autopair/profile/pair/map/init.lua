local M={}
M.maps={
    bs='backspace',
    cr='newline',
    space='space',
    fastwarp='fastwarp',
    rfastwarp='fastwarp',
}
---@param objects ua.instance
---@param conf ua.prof.pair.conf
function  M.init(objects,conf)
    for mapname,confname in pairs(M.maps) do
        local mapobj=require('ultimate-autopair.profile.pair.map.'..mapname).init(objects,conf[confname])
        if mapobj then
            table.insert(objects,mapobj)
        end
    end
end

return M
