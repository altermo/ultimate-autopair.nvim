local M={}

local _cache_filetype_is_lisp={}
function M.in_lisp_pos()
    -- TODO: if explicitly set lisp in a root filetype which is not, follow that
    local _=_cache_filetype_is_lisp
end

function M.termin_is_shell_or_vim_once()
end
function M.in_macro_once()
    return vim.fn.reg_recording()~='' or vim.fn.reg_executing()~=''
end
function M.in_mode_once()
end

function M.in_nodeclass_range()
end
function M.in_node_range()
end

-- TODO: THIS IS A GREAT FALLBACK IF TREESITTER IS SLOW!!!
-- (and also async treesitter parsing, similar to how treesitter-highlighter does it)
function M.in_comment_syntax(row,col)
    for _,id in vim.fn.synstack(row,col) do
        local name=vim.fn.synIDattr(vim.fn.synIDtrans(id),"name")
        if name=='Comment' then
            return true
        end
    end
    return false
end

---@param filters ua.iconfig.filters|ua.iconfig.filters.1|ua.iconfig.filters.2
---@param con ua.context
---@param range Range4
---@return boolean
function M.run_pos_filters(filters,con,range)
    ---TODO: temp
    for _,f in ipairs(filters) do
        if f.pos and f.pos(con,range,false) then
            return false
        end
    end
    if filters.inherited and not M.run_pos_filters(filters.inherited,con,range) then
        return false
    end
    return true
end
---@param filters ua.iconfig.filters|ua.iconfig.filters.1|ua.iconfig.filters.2
---@param con ua.context
---@return boolean
function M.run_once_filters(filters,con)
    ---TODO: temp
    for _,f in ipairs(filters) do
        if f.once and f.once(con) then
            return false
        end
    end
    if filters.inherited and not M.run_once_filters(filters.inherited,con) then
        return false
    end
    return true
end

return M
