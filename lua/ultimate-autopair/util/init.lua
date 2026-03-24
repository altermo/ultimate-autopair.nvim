local M={}

if vim.keycode('›')~='›' then
    ---@generic T:string|string?
    ---@param str T
    ---@return T
    function M.keycode(str) --TODO: once fixed in neovim, remove this
        if str and string.find(str,'[\128-\255]') then
            ---HACK: nvim_replace_termcodes converts all \x80 bytes, even if they are part of a utf8 char
            ---@cast str string
            local pos=vim.str_utf_pos(str)
            local out=''
            local sidx=1
            for k,v in ipairs(pos) do
                local c=str:sub(v,(pos[k+1] or 0)-1)
                if #c>1 and M.in_list({string.byte(c,2,-1)},128) then
                    out=out..vim.keycode(str:sub(sidx,v-1))..c
                    sidx=pos[k+1] --[[@as integer]]
                end
            end
            return out..vim.keycode(sidx and str:sub(sidx) or '')
        end
        return str and vim.keycode(str)
    end
else
    ---@generic T:string|string?
    ---@param str T
    ---@return T
    function M.keycode(str)
        return str and vim.keycode(str)
    end
end

---@generic T
---@param list (T|any)[]
---@param value T
---@return boolean
function M.in_list(list,value)
    for _,v in ipairs(list) do
        if v==value then return true end
    end
    return false
end

---@param range Range4
---@param contains_range Range4
---@param inclusive 'both'|'right'|'left'|false?
---@return boolean
function M.range_in_range(range,contains_range,inclusive)
    --If crange is zero width then and only then inclusive influence the result
    --So [f(oo)] is always true and [foo()] is true depending on if inclusive is set
    local crange=contains_range
    if crange[1]==crange[3] and crange[2]==crange[4]
        and crange[3]==range[3] and crange[4]==range[4] then
        return inclusive=='right' or inclusive=='both'
    elseif crange[1]==crange[3] and crange[2]==crange[4]
        and crange[1]==range[1] and crange[2]==range[2] then
        return inclusive=='left' or inclusive=='both'
    end
    return (range[1]<crange[1] or (range[1]==crange[1] and range[2]<=crange[2])) and
        (range[3]>crange[3] or (range[3]==crange[3] and range[4]>=crange[4]))
end

return M
