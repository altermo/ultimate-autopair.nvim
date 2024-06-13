local M={}
---@param bufnr number
---@param caches table<number,table<number,any|nil>>
function M._init(bufnr,caches)
    --TODO: implement cache invalidation on treesitter tree changes
    local cache={}
    for i=1,vim.api.nvim_buf_line_count(bufnr) do
        cache[i]=false
    end
    vim.api.nvim_buf_attach(bufnr,false,{
        on_lines=function(_,_,_,first,last,newlast)
            if last < newlast then
                for i=first+1,last do
                    cache[i]=false
                end
                for _=last,newlast-1 do
                    table.insert(cache,last+1,nil)
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
        on_detach=function()
            caches[bufnr]=nil
        end,
    })
    caches[bufnr]=cache
end
---@param bufnr number
---@param caches table<number,table<number,any|nil>>
---@return table<number,any|nil>
function M.buf_get_cache(bufnr,caches)
    if not caches[bufnr] then
        M._init(bufnr,caches)
    end
    return caches[bufnr]
end

return M
