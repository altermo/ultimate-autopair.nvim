---I
---@class ext.bigfile.conf:prof.def.ext.conf
---@field byte_limit number?
---@field row_limit number?

local M={}
local default=require'ultimate-autopair.profile.default.utils'
---@param ext prof.def.ext
---@param o core.o
---@return boolean?
---@param m prof.def.module
---@param incheck boolean?
function M.filter(ext,o,m,incheck)
    local conf=ext.conf
    ---@cast conf ext.bigfile.conf
    if conf.row_limit then
        if default.orof(conf.row_limit,o,m,incheck)<#o.lines then
            return
        end
    end
    if conf.byte_limit then
        local count=0
        for _,line in ipairs(o.lines) do
            count=count+#line+1
        end
        if default.orof(conf.byte_limit,o,m,incheck)<count then
            return
        end
    end
    return true
end
---@param m prof.def.module
---@param ext prof.def.ext
function M.call(m,ext)
    local filter=m.filter
    m.filter=function(o)
        if M.filter(ext,o,m) then
            return filter(o)
        end
    end
    local check=m.check
    m.check=function(o)
        if M.filter(ext,o,m,true) then
            return check(o)
        end
    end
end
return M
