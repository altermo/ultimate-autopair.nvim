local M={}
local open_pair=require'ultimate-autopair.configs.default.utils.open_pair'
local utils=require'ultimate-autopair.utils'
M.shells={
    'sh',
    'bash',
    'zsh',
    'fish',
}
function M.check_terminal()
    if vim.fn.mode()~='t' then return end
    local pidd=vim.fn.jobpid(vim.o.channel)
    local function f(pid)
        if not vim.tbl_contains(M.shells,vim.api.nvim_get_proc(pid).name) then return true end
        for _,v in ipairs(vim.api.nvim_get_proc_children(pid)) do
            if f(v) then return true end
        end
    end
    return f(pidd)
end
function M.add_start_pair_wrapper(pair)
    return function()
        if M.check_terminal() then return pair.start_pair end
        local o={
            line=utils.getline(),
            col=utils.getcol(),
            _nofilter=true,
        }
        if open_pair.check_start_pair(pair,o,o.col) then
            return pair.start_pair..pair.end_pair..utils.key_left
        end
        return pair.start_pair
    end
end
function M.add_end_pair_wrapper(pair)
    return function()
        if M.check_terminal() then return pair.end_pair end
        local o={
            line=utils.getline(),
            col=utils.getcol(),
            _nofilter=true,
        }
        local line=utils.getline()
        local col=utils.getcol()
        if open_pair.check_end_pair(pair,o,o.col) then
            if line:sub(col,col)==pair.end_pair then
                return utils.key_right
            end
        end
        return pair.end_pair
    end
end
function M.setup()
    local pair={
        start_pair='(',
        end_pair=')',
    }
    vim.keymap.set('t','(',M.add_start_pair_wrapper(pair),{expr=true,replace_keycodes=false})
    vim.keymap.set('t',')',M.add_end_pair_wrapper(pair),{expr=true,replace_keycodes=false})
end
return M
