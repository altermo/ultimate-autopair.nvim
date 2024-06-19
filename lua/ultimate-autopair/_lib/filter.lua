local utils=require'ultimate-autopair.utils'
local M={}
M.global={}
M.global.string={'string'} --[[TODO: add other string node types]]
M.global.comment={'comment'} --[[TODO: add other comment node types]]

---@param o ua.filter
---@param tree boolean? --TODO: maybe make this a table of options
---@return string
function M.get_filetype(o,tree)
    return utils.get_filetype(o,{tree=tree})
end
---@param _ ua.filter
---@return boolean
function M.in_macro(_)
    return vim.fn.reg_recording()~='' or vim.fn.reg_executing()~=''
end
---@param o ua.filter
---@param tree boolean? --TODO: maybe make this a table of options
---@return boolean
function M.in_lisp(o,tree)
    local ft=utils.get_filetype(o,{tree=tree})
    return utils.ft_get_option(ft,'lisp') --[[@as boolean]]
end
---@param o ua.filter
---@return boolean
function M.in_string(o)
    --NOTE: whether it is inclusive or not depends on the string, but as most strings are not inclusive
    local ret=M.in_node(o,M.global.string,false)
    if ret==nil then
        --TODO: some simple regex matching
        return false
    end
    return ret
end
---@param o ua.filter
---@return boolean
function M.in_comment(o)
    --NOTE: whether it is inclusive or not depends on the comment, but as most comments are inclusive (to the right)
    local ret=M.in_node(o,M.global.comment,true)
    if ret==nil then
        --TODO: some simple regex matching (using commentstring)
        return false
    end
    return ret
end
---@param o ua.filter
---@param node_type string|string[]
---@param inclusive boolean?
---@return boolean|nil
function M.in_node(o,node_type,inclusive)
    local parser=o.source.get_parser()
    if not parser then
        return nil
    end
    local query=require'ultimate-autopair._lib.query'
    local nodes=query.find_all_node_types(parser,type(node_type)=='string' and {node_type} or node_type --[[@as table]])
    local range={o.rows-1,o.cols-1,o.rowe-1,o.cole-1}
    for _,node in ipairs(nodes) do
        local trange={node:range()}
        if utils.range_in_range(trange,range,inclusive) then
            return true
        end
    end
    return false
end
---@param o ua.filter
---@param procnames string[]?
---@return boolean|nil
function M.term_in_shell_or_vim(o,procnames)
    if o.source.o.channel==0 then
        return nil
    end
    procnames=procnames or {
        'sh',
        'bash',
        'zsh',
        'fish',
        'nvim',
        'vim',
    }
    local function in_not_allowed_proc(pid)
        if not utils.in_list(procnames,vim.api.nvim_get_proc(pid).name) then return true end
        ---NOTE: nvim_get_proc_children sometimes doesn't return all children
        for _,v in ipairs(vim.api.nvim_get_proc_children(pid)) do
            if in_not_allowed_proc(v) then return true end
        end
    end
    return not in_not_allowed_proc(vim.fn.jobpid(vim.o.channel))
end
---@param o ua.filter
---@return boolean
function M.has_treesitter(o)
    return not not o.source.get_parser()
end
return M
