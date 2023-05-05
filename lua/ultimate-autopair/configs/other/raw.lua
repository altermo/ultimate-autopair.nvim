local M={}
function M.init_conf(conf,mem)
    for _,v in ipairs(conf) do
        table.insert(mem,v)
    end
end
return M
