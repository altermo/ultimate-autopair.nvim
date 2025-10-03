local confgen=require'ultimate-autopair.conf'
local defmerge=require'ultimate-autopair.def-merge'
local keymap=require'ultimate-autopair.keymap'

local M={}

---@param conf ua.config?
function M.setup(conf)
    conf=conf or {}
    conf=defmerge.merge_with_default(conf)
    M._conf=conf
    local iconf=confgen._generate(conf)
    M.setup_with_iconfig(iconf)
end
---@param iconf ua.iconfig
function M.setup_with_iconfig(iconf)
    keymap.set_mappings(iconf)
end
return M
