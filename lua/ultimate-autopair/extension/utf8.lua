---C
---@class ext.utf8.conf:prof.def.ext.conf
---@field map? table<string|true,string>|fun(...:prof.def.optfn):table<string|true,string>

local default=require'ultimate-autopair.profile.default.utils'
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
---@param conf ext.utf8.conf
---@param o core.o
---@param m prof.def.module
---@return string
function M.get_char(char,conf,o,m)
    local save=o.save[M.get_char] or {} o.save[M.get_char]=save
    if save[char:sub(1,vim.str_utf_end(char,1))] then return save[char:sub(1,vim.str_utf_end(char,1))] end
    for k,v in pairs(default.orof(conf.map,o,m,true) or M.map) do
        if type(k)=='string' then
            local regex=vim.regex(k) --[[@as vim.regex]]
            if regex:match_str(char) then save[char:sub(1,vim.str_utf_end(char,1))]=v return v end
        end
    end
    save[char:sub(1,vim.str_utf_end(char,1))]=M.map[true]
    return M.map[true]
end
---@param col number
---@param line string
---@param conf ext.utf8.conf
---@param o core.o
---@param m prof.def.module
---@return string?
---@return number?
---@return table<number,number>?
function M.utf8_string_and_offset(col,line,conf,o,m)
    if #line==0 then return end
    local offsets=vim.str_utf_pos(line) --[[@as table]]
    offsets[#offsets+1]=#line+1
    if offsets[#offsets]==#offsets then return end
    local newline=''
    local newcol=0
    local ncol
    for i=1,#line do
        if offsets[newcol+1]==i and offsets[newcol+2]==i+1 then
            newline=newline..line:sub(i,i)
            newcol=newcol+1
        elseif offsets[newcol+1]==i then
            newline=newline..M.get_char(line:sub(i),conf,o,m)
            newcol=newcol+1
        end
        if i==col then ncol=newcol end
    end
    if col==#line+1 then ncol=newcol+1 end
    return newline,ncol,offsets
end
---@param off (table<number,number>)[]
---@return fun(col:number,row:number):number
function M.wrapp_coloffset(off)
    return function (col,row)
        if not off[row] then return 0 end
        while not off[row][col] and col>0 do col=col-1 end
        if col==0 then return 0 end
        return off[row][col]-col
    end
end
---@param m prof.def.module
---@param ext prof.def.ext
function M.call(m,ext)
    local conf=ext.conf
    ---@cast conf ext.utf8.conf
    local check=m.check
    m.check=function (o)
        local col
        local off={}
        local of
        local lline
        for row,line in ipairs(o.lines) do
            lline,col,of=M.utf8_string_and_offset(o.col,line,conf,o,m)
            if lline and col and of then
                o.lines[row]=lline
                off[row]=of
                if row==o.row then o.col=col end
            end
        end
        o.line=o.lines[o.row]
        o._coloffset=M.wrapp_coloffset(off)
        local deoff={}
        for row,offf in pairs(off) do
            deoff[row]={}
            for k,v in pairs(offf) do
                deoff[row][v]=k
            end
        end
        o._decoloffset=M.wrapp_coloffset(deoff)
        return check(o)
    end
end
return M
