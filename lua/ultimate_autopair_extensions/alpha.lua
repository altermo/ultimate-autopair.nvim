local alpha=[=[\v[[=a=][=b=][=c=][=d=][=e=][=f=][=g=][=h=][=i=][=j=][=k=][=l=][=m=][=n=][=o=][=p=][=q=][=r=][=s=][=t=][=u=][=v=][=w=][=x=][=y=][=z=]]]=]
return {call=function (o,keyconf,conf)
    if conf.alpha or keyconf.alpha then
        if o.key=='"' or o.key=="'" and vim.o.filetype=='python' and not conf.no_python then
            if vim.regex([[\v\c<((r[fb])|([fb]r)|[frub])$]]):match_str(o.line:sub(o.col-3,o.col-1)) then
                return
            end
        end
        if vim.regex(alpha):match_str(vim.fn.strcharpart(o.line,o.col-2,1)) then
            return 3
        end
    end
    if conf.after or keyconf.alpha_after then
        if vim.regex(alpha):match_str(vim.fn.strcharpart(o.line,o.col-2,1)) then
            return 3
        end
    end
end}
