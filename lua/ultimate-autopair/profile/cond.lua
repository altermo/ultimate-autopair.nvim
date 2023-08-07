---@class prof.cond.conf:prof.config
---@field filter core.filter-fn

local prof=require'ultimate-autopair.prof_init'
local M={}
---@param conf prof.cond.conf
---@param mem core.module[]
function M.init(conf,mem)
    local lmem={}
    prof.init(conf,lmem)
    for _,v in ipairs(lmem) do
        if v.filter then
            local filter=v.filter
            v.filter=function (o)
                if not conf.filter(o) then return end
                return filter(o)
            end
        end
        table.insert(mem,v)
    end
end
return M
