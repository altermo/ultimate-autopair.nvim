--Internal
local M={}
M.I={
    args_to_tuple=function(...)
        return vim.inspect({...})
    end
}
M.cache={}
M.lifetime={
    unalteredbuf='unalteredbuf',
}
function M.reset_cache(lifetime)
    M.cache[lifetime]={}
end
function M.cache_fn(fn,lifetime)
    return function (...)
        local cache=M.cache[lifetime]
        if not cache then return fn(...) end
        local key=M.I.args_to_tuple(...)
        if cache[key] then return unpack(cache[key]) end
        local ret={fn(...)}
        cache[key]=ret
        return unpack(ret)
    end
end
return M
