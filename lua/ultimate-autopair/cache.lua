---@alias ua.cache table<number,any|nil>
local M={}
---@param bufnr number
---@param cache ua.cache
function M._attach_textchange(bufnr,cache)
    vim.api.nvim_buf_attach(bufnr,false,{
        on_lines=function(_,_,_,first,last,newlast)
            if last<newlast then
                for i=first+1,last do
                    cache[i]=false
                end
                for _=last,newlast-1 do
                    table.insert(cache,last+1,false)
                end
            elseif last==newlast then
                for i=first+1,last do
                    cache[i]=false
                end
            else
                for i=first+1,newlast do
                    cache[i]=false
                end
                for _=newlast,last-1 do
                    table.remove(cache,newlast+1)
                end
            end
            assert(#cache==vim.api.nvim_buf_line_count(bufnr))
        end,
    })
end
---@param bufnr number
---@param cache ua.cache
---@param opt string
function M._attach_opt(bufnr,cache,opt)
    local id=vim.api.nvim_create_autocmd('OptionSet',{
        pattern=opt,
        callback=function()
            if vim.api.nvim_get_current_buf()~=bufnr then
                return
            end
            for i=1,#cache do
                cache[i]=false
            end
        end,
    })
    vim.api.nvim_buf_attach(bufnr,false,{
        on_detach=function()
            pcall(vim.api.nvim_del_autocmd,id)
        end,
    })
end
---@param bufnr number
---@param caches table<number,ua.cache>
---@param opts string[]?
function M._init(bufnr,caches,opts)
    opts=opts or {'textchange'} --TODO: temp
    local cache={}
    for i=1,vim.api.nvim_buf_line_count(bufnr) do
        cache[i]=false
    end
    vim.api.nvim_buf_attach(bufnr,false,{
        on_detach=function()
            caches[bufnr]=nil
        end,
    })
    caches[bufnr]=cache
    for _,opt in ipairs(opts) do
        if opt=='textchange' then
            M._attach_textchange(bufnr,cache)
        elseif opt=='treechange' then
            --TODO: implement cache invalidation on treesitter tree changes
        elseif opt:sub(1,4)=='opt:' then
            M._attach_opt(bufnr,cache,opt:sub(5))
        end
    end
end
---@param bufnr number
---@param caches table<number,ua.cache>
---@param opts string[]?
---@return ua.cache
function M.buf_get_cache(bufnr,caches,opts)
    if not caches[bufnr] then
        M._init(bufnr,caches,opts)
    end
    return caches[bufnr]
end
---@return table<any,table>
function M.weak_defaulttable()
    return setmetatable({},{
        __mode="k",
        __index=function(t,k)
            rawset(t,k,{})
            return t[k]
        end,
    })
end
return M
