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
                    sidx=pos[k+1]
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

return M
