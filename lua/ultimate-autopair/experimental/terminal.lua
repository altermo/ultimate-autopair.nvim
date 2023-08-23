local M={}
local open_pair=require'ultimate-autopair.profile.default.utils.open_pair'
local utils=require'ultimate-autopair.utils'
M.white_list_processes={
    'sh',
    'bash',
    'zsh',
    'fish',
    'nvim',
    'vim',
}
---@return boolean?
function M.check_terminal()
    if vim.fn.mode()~='t' then return end
    return M.in_allowed_process()
end
---@return boolean?
function M.in_allowed_process()
    local function f(pid)
        if not vim.tbl_contains(M.white_list_processes,vim.api.nvim_get_proc(pid).name) then return true end
        for _,v in ipairs(vim.api.nvim_get_proc_children(pid)) do
            if f(v) then return true end
        end
    end
    return f(vim.fn.jobpid(vim.o.channel))
end
---@param pair prof.def.m.pair
---@return fun():string
function M.add_start_pair_wrapp(pair)
    return function()
        if M.in_allowed_process() then return pair.start_pair end
        local o={
            line=utils.getline(),
            col=utils.getcol(),
            row=1,
            lines={utils.getline()},
        }
        if not open_pair.open_end_pair_after(pair,o,o.col) then
            return pair.start_pair..pair.end_pair..utils.key_left
        end
        return pair.start_pair
    end
end
function M.add_end_pair_wrapp(pair)
    return function()
        if M.in_allowed_process() then return pair.end_pair end
        local o={
            line=utils.getline(),
            col=utils.getcol(),
            row=1,
            lines={utils.getline()},
        }
        local line=utils.getline()
        local col=utils.getcol()
        if not open_pair.open_start_pair_before(pair,o,o.col) then
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
        start_m={filter=function () return true end},
        end_m={filter=function () return true end}
    }
    vim.keymap.set('t','(',M.add_start_pair_wrapp(pair),{expr=true,replace_keycodes=false})
    vim.keymap.set('t',')',M.add_end_pair_wrapp(pair),{expr=true,replace_keycodes=false})
end
return M
