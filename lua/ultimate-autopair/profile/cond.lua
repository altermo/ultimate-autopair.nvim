local utils=require'ultimate-autopair.utils'
local profile=require'ultimate-autopair.profile'
local M={}
---@param conf table
---@param objects ua.instance
function M.init(conf,objects)
    local filter=conf.filter
    ---@type ua.instance
    local lobjects={}
    profile.init(conf,lobjects)
    for _,v in ipairs(lobjects) do
        local run=assert(v.run)
        v.run=function (o)
            if not utils.run_filters(filter,o) then
                return
            end
            return run(o)
        end
        table.insert(objects,v)
    end
end
return M
