local M={}
local open_pair=require'ultimate-autopair.configs.default.utils.open_pair'
local utils=require'ultimate-autopair.utils'
function M.add_start_pair_wrapper(start_pair,end_pair)
    return function()
        if open_pair.check_start_pair(start_pair,end_pair,utils.getline(),utils.getcol()) then
            return start_pair..end_pair..utils.key_left
        end
        return start_pair
    end
end
function M.add_end_pair_wrapper(start_pair,end_pair)
    return function()
        local line=utils.getline()
        local col=utils.getcol()
        if open_pair.check_end_pair(start_pair,end_pair,line,col) then
            if line:sub(col,col)==end_pair then
                return utils.key_right
            end
        end
        return end_pair
    end
end
function M.setup()
    vim.keymap.set('t','(',M.add_start_pair_wrapper('(',')'),{expr=true,replace_keycodes=false})
    vim.keymap.set('t',')',M.add_end_pair_wrapper('(',')'),{expr=true,replace_keycodes=false})
end
return M
