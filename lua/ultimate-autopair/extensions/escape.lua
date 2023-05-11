local default=require'ultimate-autopair.configs.default.utils'
return default.wrapp_old_extension(function(o,keyconf,conf)
    if keyconf.noescape then return end
    if not (conf.nochar or keyconf.nocharescape) then
        local col=o.col-1
        local escape=false
        while o.line:sub(col,col)=='\\' do
            col=col-1
            escape=not escape
        end
        if escape then return 2 end
    end
    if conf.nofilter or keyconf.nofilterescape then return end
    local newline=''
    local escape=false
    for i=1,#o.line do
        local char=o.line:sub(i,i)
        if escape then
            escape=false
            newline=newline..'\1'
        elseif char=='\\' then
            escape=true
            newline=newline..char
        else
            newline=newline..char
        end
    end
    o.line=newline
end)
