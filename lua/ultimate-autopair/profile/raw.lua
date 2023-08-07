local M={}
---@param conf core.module[]
---@param mem core.module[]
function M.init(conf,mem)
    for _,v in ipairs(conf) do
        table.insert(mem,v)
    end
end
return M
