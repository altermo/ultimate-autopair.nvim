local hookutils=require'ultimate-autopair.hook.utils'
local M={}
---@param map table
---@return ua.object
function M.create_map(map)
    local modes=type(map[1])=='string' and {map[1]} or map[1] --[[@as string[] ]]
    local lhs=map[2]
    local rhs=map[3]
    local hooks={}
    for _,mode in ipairs(modes) do
        table.insert(hooks,hookutils.to_hash('map',lhs,{mode=mode}))
    end
    return {
        run=function (o)
            if type(rhs)=='function' then return {(rhs(o))} end
            return {rhs}
        end,
        hooks=hooks,
        doc=('map %s to %s'):format(vim.inspect(lhs),vim.inspect(rhs))
    }
end
---@param conf table
---@param objects ua.instance
function M.init(conf,objects)
    for _,map in ipairs(conf) do
        table.insert(objects,M.create_map(map))
    end
end
return M
