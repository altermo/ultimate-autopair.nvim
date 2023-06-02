local default=require'ultimate-autopair.configs.default.utils'
local alpha=[=[\v[[=a=][=b=][=c=][=d=][=e=][=f=][=g=][=h=][=i=][=j=][=k=][=l=][=m=][=n=][=o=][=p=][=q=][=r=][=s=][=t=][=u=][=v=][=w=][=x=][=y=][=z=]]]=]
return default.wrapp_old_extension(function (o,keyconf,conf)
    if conf.alpha or keyconf.alpha then
        if o.key=='"' or o.key=="'" and vim.o.filetype=='python' and not conf.no_python then
            if vim.regex([[\v\c<((r[fb])|([fb]r)|[frub])$]]):match_str(o.line:sub(o.col-3,o.col-1)) then
                return
            end
        end
        if vim.regex(alpha):match_str(o.line:sub(vim.str_utf_start(o.line,o.col-1)+o.col-1,o.col-1)) then
            return 3
        end
    end
    if conf.after or keyconf.alpha_after then
        if vim.regex(alpha):match_str(o.line:sub(o.col,vim.str_utf_end(o.line,o.col)+o.col)) then
            return 3
        end
    end
end)
