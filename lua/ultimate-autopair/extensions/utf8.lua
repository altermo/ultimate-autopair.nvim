local M={}
M.map={
    ['[=a=]']='a',
    ['[=b=]']='b',
    ['[=c=]']='c',
    ['[=d=]']='d',
    ['[=e=]']='e',
    ['[=f=]']='f',
    ['[=g=]']='g',
    ['[=h=]']='h',
    ['[=i=]']='i',
    ['[=j=]']='j',
    ['[=k=]']='k',
    ['[=l=]']='l',
    ['[=m=]']='m',
    ['[=n=]']='n',
    ['[=o=]']='o',
    ['[=p=]']='p',
    ['[=q=]']='q',
    ['[=r=]']='r',
    ['[=s=]']='s',
    ['[=t=]']='t',
    ['[=u=]']='u',
    ['[=v=]']='v',
    ['[=w=]']='w',
    ['[=x=]']='x',
    ['[=y=]']='y',
    ['[=z=]']='z',
    [true]='\x01',
}
function M.get_char(char,conf)
    for k,v in pairs(conf.map or M.map) do
        if type(k)=='string' then
            local regex=vim.regex('\\v['..k..']')
            if regex:match_str(char) then
                return v
            end
        end
    end
    return M.map[true]
end
function M.call(m,ext)
    local conf=ext.conf
    local check=m.check
    m.check=function (o)
        local newline=''
        local newcol=0
        for i=1,#o.line do
            if vim.str_utf_end(o.line,i)>0 and vim.str_utf_start(o.line,i)==0 then
                newline=newline..M.get_char(o.line:sub(i),conf)
                newcol=newcol+1
            elseif vim.str_utf_start(o.line,i)==0 then
                newline=newline..o.line:sub(i,i)
                newcol=newcol+1
            end
            if i==o.col then o.col=newcol end
        end
        if o.col==#o.line+1 then o.col=newcol+1 end
        o.line=newline
        return check(o)
    end
end
return M
