---@class ua.prof.pair.map.conf
---@field modes string[]
---@field map string|table
---@field p? number
---@field enable? boolean

local M={}
---@param conf ua.prof.pair.conf
---@param objects ua.instance
function M.init(conf,objects)
    local somepairs={}
    M.init_pairs(somepairs,conf)
    M.pair_sort_len(somepairs)
    for _,v in ipairs(somepairs) do
        table.insert(objects,v)
    end
    M.init_maps(objects,conf)
end
---@param somepairs ua.prof.pair.pair[]
function M.pair_sort_len(somepairs)
    local len={}
    for _,v in ipairs(somepairs) do
        local l=-(#v.main_pair or -1)
        if not len[l] then len[l]={} end
        table.insert(len[l],v)
    end
    local k=1
    for _,v in vim.spairs(len) do
        for _,i in ipairs(v) do
            somepairs[k]=i
            k=k+1
        end
    end
end
---@param somepairs ua.prof.pair.pair[]
---@param conf ua.prof.pair.conf
function M.init_pairs(somepairs,conf)
    for _,pair in ipairs(conf) do
        for _,module in ipairs(M.init_pair(pair)) do
            table.insert(somepairs,module)
        end
    end
end
---@param pair ua.prof.pair.conf.pair
---@return ua.prof.pair.pair[]
function M.init_pair(pair)
    return require('ultimate-autopair.profile.pair.pair').init(pair)
end
---@param objects ua.instance
---@param conf ua.prof.pair.conf
function M.init_maps(objects,conf)
    require('ultimate-autopair.profile.pair.map').init(objects,conf)
end
return M
