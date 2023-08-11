---@class prof.cond.conf:prof.config
---@field filter? core.filter-fn
---@field check? core.filter-fn

local prof=require'ultimate-autopair.prof_init'
local M={}
---@param conf prof.cond.conf
---@param mem core.module[]
function M.init(conf,mem)
    local lmem={}
    local filter_=conf.filter or function () return true end
    local check_=conf.check or conf.check~=false and filter_ or function () return true end
    prof.init(conf,lmem)
    for _,v in ipairs(lmem) do
        if v.filter then
            local filter=v.filter
            v.filter=function (o)
                if not filter_(o) then return end
                return filter(o)
            end
        end
        if v.check then
            local check=v.check
            v.check=function (o)
                if not check_(o) then return end
                return check(o)
            end
        end
        table.insert(mem,v)
    end
end
return M
