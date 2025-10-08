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

---@param fn_name string
---@param do_ret boolean
local function run_filters_fn(fn_name,do_ret)
    ---@param filters ua.iconfig.filters|ua.iconfig.filters.1|ua.iconfig.filters.2
    local function fn(filters,...)
        for _,f in ipairs(filters) do
            if f[fn_name] and f[fn_name](...) and do_ret then
                return false
            end
        end
        if filters.inherited and not fn(filters.inherited,...) and do_ret then
            return false
        end
        if filters.inherited_root and not fn(filters.inherited_root,...) and do_ret then
            return false
        end
        return true
    end
    return fn
end

---@alias ua.filters_all ua.iconfig.filters|ua.iconfig.filters.1|ua.iconfig.filters.2

---@overload fun(filters: ua.filters_all, con: ua.context,range: Range4, in_iter: boolean?): boolean
M.run_pos_filters=run_filters_fn('pos',true)

---@overload fun(filters: ua.filters_all, con: ua.context): boolean
M.run_once_filters=run_filters_fn('once',true)

---@overload fun(filters: ua.filters_all, con: ua.context, range: Range4, type_: 'normal'|'reverse')
M.run_on_iter_filters=run_filters_fn('on_iter',false)

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
