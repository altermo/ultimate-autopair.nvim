---@alias ua.query.langs {[1]:string,[2]:TSNode}
local M={}
---@param root_parser vim.treesitter.LanguageTree
---@return ua.query.langs
function M.get_lang_root_nodes(root_parser)
    local children={root_parser}
    local ret={}
    while true do
        ---@type vim.treesitter.LanguageTree
        local parser=table.remove(children,1)
        if not parser then return ret end
        local lang=parser:lang()
        local trees=parser:trees()
        for _,tree in ipairs(trees) do
            table.insert(ret,{lang,tree:root()})
        end
        vim.list_extend(children,parser:children())
    end
end
---@type table<string,table<string,boolean>>
M._cache_lang_node_types=vim.defaulttable(function() return {} end)
---@param node_types string[]
---@param lang string
---@return string[]
function M.filter_invalid_node_types(node_types,lang)
    local cache=M._cache_lang_node_types[lang]
    local ret={}
    for _,node_type in ipairs(node_types) do
        if cache[node_type]==nil then
            cache[node_type]=pcall(vim.treesitter.query.parse,lang,('(%s)'):format(node_type))
        end
        if cache[node_type] then
            table.insert(ret,node_type)
        end
    end
    return ret
end
---@param node_types string[]
---@return string
function M.node_types_to_query_str(node_types)
    return table.concat(vim.tbl_map(function(v) return ('((%s) @%s)'):format(v,v) end,node_types))
end
M._cache_query=vim.defaulttable(function(lang)
    return vim.defaulttable(function(query_str)
        return vim.treesitter.query.parse(lang,query_str)
    end)
end)
---@param parser vim.treesitter.LanguageTree
---@param node_types string[]
function M.find_all_node_types(parser,node_types)
    local cache_query=vim.defaulttable(function (lang)
        local query_str=M.node_types_to_query_str(M.filter_invalid_node_types(node_types,lang))
        return M._cache_query[lang][query_str]
    end)
    local ret={}
    parser:for_each_tree(function(tree,ltree)
        local lang=ltree:lang()
        local query=cache_query[lang]
        for _,node in query:iter_captures(tree:root(),ltree:source(),0,-1) do
            table.insert(ret,node)
        end

    end)
    return ret
end
return M
