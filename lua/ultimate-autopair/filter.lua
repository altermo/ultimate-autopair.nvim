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
---@param in_iter boolean?
---@return boolean
function M.run_pos_filters(filters,con,range,in_iter)
    ---TODO: temp
    for _,f in ipairs(filters) do
        if f.pos and f.pos(con,range,in_iter or false) then
            return false
        end
    end
    if filters.inherited and not M.run_pos_filters(filters.inherited,con,range,in_iter) then
        return false
    end
    if filters.inherited_root and not M.run_pos_filters(filters.inherited_root,con,range,in_iter) then
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
    if filters.inherited_root and not M.run_once_filters(filters.inherited_root,con) then
        return false
    end
    return true
end
---@param filters ua.iconfig.filters|ua.iconfig.filters.1|ua.iconfig.filters.2
---@param con ua.context
---@param range Range4
---@param type_ 'normal'|'reverse'
function M.run_on_iter_filters(filters,con,range,type_)
    ---TODO: temp
    for _,f in ipairs(filters) do
        if f.on_iter then f.on_iter(con,range,type_) end
    end
    if filters.inherited then M.run_on_iter_filters(filters.inherited,con,range,type_) end
    if filters.inherited_root then M.run_on_iter_filters(filters.inherited_root,con,range,type_) end
end
---@param con ua.context
---@param start_pair_conf ua.iconfig.single_pair
---@param end_pair_conf ua.iconfig.single_pair
---@param start_pair string
---@param end_pair string
---@return [{on_init:fun(...),pos:fun(row,col):boolean},{on_init:fun(...),pos:fun(row,col):boolean}]
function M.pair_to_filters(con,start_pair_conf,end_pair_conf,start_pair,end_pair)
    return {
        {on_init=function(...)
            M.run_on_iter_filters(start_pair_conf.filter,...)
        end,pos=function (row,col)
                local range={row-1,col-1,row-1,col-1+#start_pair}
                return M.run_pos_filters(start_pair_conf.filter,con,range,true)
            end},
        {on_init=function(...)
            M.run_on_iter_filters(end_pair_conf.filter,...)
        end,pos=function (row,col)
                local range={row-1,col-2+#end_pair,row-1,col-2+#end_pair+#end_pair}
                return M.run_pos_filters(end_pair_conf.filter,con,range,true)
            end}
    }
end

return M
