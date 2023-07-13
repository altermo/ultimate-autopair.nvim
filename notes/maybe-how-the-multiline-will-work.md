# How the multiline will work
Currently this plugin does not implement multiline pair detection, this note will try to remade that by writing some suggestions on how to implement such feature.
## What we want
+ Make it detect open/closed pairs multiline-wise (obviously)
+ Don't make it slow (where file is ~200 lines and ~100 chars)
+ Make better filtering system (for not detecting 1 open pair in string 150 lines before)
## 1 idea: caching
The first idea of how to implement this is by caching the result after parsing line.\
Here's some pseudo code for how to maybe implement it:
```lua
function Cache:append(info,parsed)
    if #self>config.max_cache_size then
        self:clear_to(config.max_cache_size)
    end
    self[info]=parsed
end
function M.gen_info(line,conf)
    local info={}
    table.insert(info,line)
    if not conf.no_ts and M.ts_enabled() then
        table.insert(info,M.gen_ts_info())
    end
    for _,fn in ipairs(conf.cache_hashes or {}) do
        table.insert(info,fn(line,conf))
    end
    return vim.json.encode(info)
end
function M.parse_line_cashed(cache,parser,line,conf)
    local info=M.gen_info(line,conf or {})
    if cache[info] then return cache[info] end
    local parsed=parser(line)
    cache:append(info,parsed)
    return parsed
end
```