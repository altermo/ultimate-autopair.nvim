local hookutils=require'ultimate-autopair.hook.utils'
local M={}
---@param map table
---@param priority number
---@return ua.object
function M.create_map(map,priority)
    local modes=type(map[1])=='string' and {map[1]} or map[1] --[[@as string[] ]]
    local lhs=map[2]
    local rhs=map[3]
    local keycode=map.keycode~=false
    local hooks={}
    for _,mode in ipairs(modes) do
        table.insert(hooks,hookutils.to_hash('map',lhs,mode))
    end
    return {
        run=function (o)
            --TODO: test for non insert/cmdline mode map
            local ret=''
            if type(rhs)=='function' then
                ret=rhs(o)
            else
                ret=rhs
            end
            if ret and keycode then
                ret=vim.api.nvim_replace_termcodes(ret,true,true,true)
            end
            return {ret}
        end,
        hooks=hooks,
        doc=('map %s to %s'):format(vim.inspect(lhs),vim.inspect(rhs)),
        p=priority,
    }
end
---@param conf table
---@param objects ua.instance
function M.init(conf,objects)
    for _,map in ipairs(conf) do
        table.insert(objects,M.create_map(map,map.p or conf.p))
    end
end
return M
