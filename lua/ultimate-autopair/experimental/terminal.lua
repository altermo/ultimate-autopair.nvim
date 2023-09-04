local M={}
---Instruction: if you want TO USE THIS
--use
---require'ultimate-autopair.core'.modes={'i','c','t'}
---require'ultimate-autopair'.init({your_pair_config,{
---  profile='raw',
---  unpack(require'ultimate-autopair.experimental.terminal'.init()),
---}})
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
    return M.in_not_allowed_process()
end
---@return boolean?
function M.in_not_allowed_process()
    local function f(pid)
        if not vim.tbl_contains(M.white_list_processes,vim.api.nvim_get_proc(pid).name) then return true end
        for _,v in ipairs(vim.api.nvim_get_proc_children(pid)) do
            if f(v) then return true end
        end
    end
    return f(vim.fn.jobpid(vim.o.channel))
end
---@param start_pair string
---@param end_pair string
---@return core.module
function M.init_start_pair(start_pair,end_pair)
    local m={
        filter=function () return true end,
        end_m={filter=function () return true end},
        start_m={filter=function () return true end},
        start_pair=start_pair,
        end_pair=end_pair,
        p=10,
        doc=('autopairs terminal start pair: %s,%s'):format(start_pair,end_pair),
    }
    m.get_map=function (mode) if mode=='t' then return {start_pair} end end
    m.check=function (o)
        if o.mode~='t' or o.key~=start_pair then return end
        if M.in_not_allowed_process() then return end
        if open_pair.open_end_pair_after(m,o,o.col) then return end
        return m.start_pair..m.end_pair..utils.key_left
    end
    return m
end
---@param start_pair string
---@param end_pair string
---@return core.module
function M.init_end_pair(start_pair,end_pair)
    local m={
        filter=function () return true end,
        end_m={filter=function () return true end},
        start_m={filter=function () return true end},
        start_pair=start_pair,
        end_pair=end_pair,
        p=10,
        doc=('autopairs terminal end pair: %s,%s'):format(start_pair,end_pair),
    }
    m.get_map=function (mode) if mode=='t' then return {end_pair} end end
    m.check=function (o)
        if o.mode~='t' or o.key~=end_pair then return end
        if M.in_not_allowed_process() then return end
        if open_pair.open_start_pair_before(m,o,o.col) then return end
        if o.line:sub(o.col,o.col)~=m.end_pair then return end
        return utils.key_right
    end
    return m
end
---@return core.module[]
function M.init()
    return {
        M.init_start_pair('(',')'),
        M.init_end_pair('(',')')
    }
end
return M
