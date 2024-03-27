local hookutils=require'ultimate-autopair.hook.utils'
local M={}
---@param opts table
---@return ua.object
function M.create_obj(opts)
    local hooks={}
    if opts.hooks then
        for _,v in ipairs(opts.hooks) do
            table.insert(hooks,hookutils.to_hash(unpack(v)))
        end
    else
        hooks[1]=hookutils.to_hash(unpack(opts[1]))
    end
    return {
        run=opts.run or opts[2],
        hooks=hooks,
        doc=opts.doc,
        p=opts.p,
    }
end
---@param conf table
---@param objects ua.instance
function M.init(conf,objects)
    for _,map in ipairs(conf) do
        table.insert(objects,M.create_obj(map))
    end
end
return M
