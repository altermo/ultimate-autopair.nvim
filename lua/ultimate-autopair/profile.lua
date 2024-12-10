local pair=require'ultimate-autopair.pair'
local M={}

---@param iconf ua.iconfig._pair[]
---@param out_hooks ua.hook[]
local function init_pairs(out_hooks,iconf)
    local ps={}
    local t_start=vim.defaulttable(function () return {} end)
    local t_end=vim.defaulttable(function () return {} end)
    for _,pair_conf in ipairs(iconf) do
        local start_hooks,end_hooks,start_pair_p,end_pair_p=pair.init(pair_conf)
        ps[-start_pair_p]=true
        ps[-end_pair_p]=true
        for _,hook in ipairs(start_hooks) do
            table.insert(t_start[start_pair_p],hook)
        end
        for _,hook in ipairs(end_hooks) do
            table.insert(t_end[end_pair_p],hook)
        end
    end
    for p in vim.spairs(ps) do
        p=-p
        for _,hook in ipairs(t_end[p]) do
            table.insert(out_hooks,hook)
        end
        for _,hook in ipairs(t_start[p]) do
            table.insert(out_hooks,hook)
        end
    end
end

---@param iconf ua.iconfig
---@return ua.hook[]
function M.init(iconf)
    local hooks={}
    init_pairs(hooks,iconf._pairs)
    --TODO: init maps
    return hooks
end
return M
