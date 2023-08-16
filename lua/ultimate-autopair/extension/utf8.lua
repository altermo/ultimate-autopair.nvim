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
---@param col number
---@param line string
---@param conf table
---@return string
---@return number
---@return table<number,number>
function M.transform(col,line,conf)
    local newline=''
    local newcol=0
    local ncol
    for i=1,#line do
        if vim.str_utf_end(line,i)>0 and
            vim.str_utf_start(line,i)==0 then
            newline=newline..M.get_char(line:sub(i),conf)
            newcol=newcol+1
        elseif vim.str_utf_start(line,i)==0 then
            newline=newline..line:sub(i,i)
            newcol=newcol+1
        end
        if i==col then ncol=newcol end
    end
    if col==#line+1 then ncol=newcol+1 end
    local offsets=vim.str_utf_pos(line) --[[@as table]]
    offsets[#offsets+1]=#line+1
    return newline,ncol,offsets
end
---@param off (table<number,number>)[]
---@param neg? boolean
---@return fun(col:number,row:number):number
function M.wrapp_coloffset(off,neg)
    return function (col,row)
        return (col-off[row][col])*(neg and -1 or 1)
    end
end
---@param m prof.def.module
---@param ext prof.def.ext
function M.call(m,ext)
    local conf=ext.conf
    local check=m.check
    m.check=function (o)
        local col
        local off={}
        for row,line in ipairs(o.lines) do
            o.lines[row],col,off[row]=M.transform(o.col,line,conf)
            if row==o.row then
                o.col=col
            end
        end
        o.line=o.lines[o.row]
        o._coloffset=M.wrapp_coloffset(off)
        local deoff={}
        for row,of in pairs(off) do
            deoff[row]={}
            for k,v in pairs(of) do
                deoff[row][v]=k
            end
        end
        o.s=deoff
        o._decoloffset=M.wrapp_coloffset(deoff,true)
        return check(o)
    end
end
return M
