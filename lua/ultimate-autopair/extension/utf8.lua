---C
local M={}
M.type={}
M.map={
    ['\\v[[=a=]]']='a',
    ['\\v[[=b=]]']='b',
    ['\\v[[=c=]]']='c',
    ['\\v[[=d=]]']='d',
    ['\\v[[=e=]]']='e',
    ['\\v[[=f=]]']='f',
    ['\\v[[=g=]]']='g',
    ['\\v[[=h=]]']='h',
    ['\\v[[=i=]]']='i',
    ['\\v[[=j=]]']='j',
    ['\\v[[=k=]]']='k',
    ['\\v[[=l=]]']='l',
    ['\\v[[=m=]]']='m',
    ['\\v[[=n=]]']='n',
    ['\\v[[=o=]]']='o',
    ['\\v[[=p=]]']='p',
    ['\\v[[=q=]]']='q',
    ['\\v[[=r=]]']='r',
    ['\\v[[=s=]]']='s',
    ['\\v[[=t=]]']='t',
    ['\\v[[=u=]]']='u',
    ['\\v[[=v=]]']='v',
    ['\\v[[=w=]]']='w',
    ['\\v[[=x=]]']='x',
    ['\\v[[=y=]]']='y',
    ['\\v[[=z=]]']='z',
    [true]='\x01',
}
---@param char string
---@param conf table
---@return string
function M.get_char(char,conf)
    for k,v in pairs(conf.map or M.map) do
        if type(k)=='string' then
            local regex=vim.regex(k) --[[@as vim.regex]]
            if regex:match_str(char) then return v end
        end
    end
    return M.map[true]
end
---@param o core.o
---@param conf table
function M.transform(o,conf)
    if o.save[M.type] then return end
    local newline=''
    local newcol=0
    for i=1,#o.line do
        if vim.str_utf_end(o.line,i)>0 and
            vim.str_utf_start(o.line,i)==0 then
            newline=newline..M.get_char(o.line:sub(i),conf)
            newcol=newcol+1
        elseif vim.str_utf_start(o.line,i)==0 then
            newline=newline..o.line:sub(i,i)
            newcol=newcol+1
        end
    end
    if o.col==#o.line+1 then o.col=newcol+1 end
    o.line=newline
    o.save[M.type]=true
end
---@param m prof.def.module
---@param ext prof.def.ext
function M.call(m,ext)
    local conf=ext.conf
    local check=m.check
    m.check=function (o)
        --for _,v in ipairs(o.lines) do
        --end --TODO
        M.transform(o,conf)
        return check(o)
    end
    --TODO: maybe implement for filter
end
return M
