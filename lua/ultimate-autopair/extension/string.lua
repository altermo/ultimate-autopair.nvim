---F
local M={}
M.type={}
---@param m prof.def.module
---@param ext prof.def.ext
function M.call(m,ext)
    local check=m.check
    local conf=ext.conf
    m.check=function (o)
        local save={}
        o.save[M.type]=save
        save.currently_filtering=true
        save.instring,save.stringstart,save.stringend=M.inserting(o,save,conf)
        save.currently_filtering=nil
        return check(o)
    end
    local filter=m.filter
    m.filter=function(o)
        local save=o.save[M.save_type]
        if not save or save.currently_filtering then return filter(o) end
        save.currently_filtering=true
        if M.filter(o,save,conf) then
            save.currently_filtering=nil
            return filter(o)
        end
        save.currently_filtering=nil
    end
end
--TODO: continue
return M
