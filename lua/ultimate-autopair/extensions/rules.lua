local default=require'ultimate-autopair.configs.default.utils'
local M={}
function M.check_rule(rule,o)
    local cmd=rule[1]
    local args={unpack(rule,2)}
    if cmd=='not' then
        return not M.check_rule(args[1],o)
    elseif cmd=='when' then
        for i=1,#args/2 do
            if M.check_rule(args[i*2-1],o) then
                return M.check_rule(args[i*2],o)
            end
        end
        if #args%2==1 then
            return M.check_rule(args[#args],o)
        else
            return true
        end
    elseif cmd=='and' then
        for _,v in ipairs(args) do
            if not M.check_rule(v,o) then
                return false
            end
        end
        return true
    elseif cmd=='or' then
        for _,v in ipairs(args) do
            if M.check_rule(v,o) then
                return true
            end
        end
        return false
    elseif cmd=='next' then
        return o.line:sub(o.col+(args[2] or 1)-1,o.col+(args[2] or 1)-1)==args[1]
    elseif cmd=='previous' then
        return o.line:sub(o.col-(args[2] or 1),o.col-(args[2] or 1))==args[1]
    elseif cmd=='filetype' then
        return vim.tbl_contains(args,vim.o.filetype)
    elseif cmd=='option' then
        if #args==1 then
            return vim.o[args[1]]
        else
            return vim.o[args[1]]==args[2]
        end
    elseif cmd=='call' then
        return args[1](o,unpack(args,2))
    elseif cmd=='instring' then
        return require'ultimate-autopair.extensions.string'.instring(o.line,o.col,o.linenr,args[1])
    else
        error(("Unknown command %s"):format(cmd))
    end
end
function M.check_rules(rules,o)
    for _,v in ipairs(rules) do
        if not M.check_rule(v,o) then
            return false
        end
    end
    return true
end
function M.init(rules,mem)
    if rules then
        for _,v in ipairs(rules) do
            mem[#mem+1]=v
        end
    end
end
return default.wrapp_old_extension(function (o,keyconf)
    if not keyconf.rules then return end
    if M.check_rules(keyconf.rules,o) then
        return
    end
    return 2
end,M)
