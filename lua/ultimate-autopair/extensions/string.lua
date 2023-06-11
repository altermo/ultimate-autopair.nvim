local M={}
local default=require'ultimate-autopair.configs.default.utils'
function M.instring(line,col,linenr,notree)
    for _,i in ipairs(default.filter_pair_type({'pairo','pair'})) do
        if not i.conf.string then goto continue end
        local isin,start,_end=i.fn.in_pair(line,col,{notree=notree,linenr=linenr})
        if isin then return isin, start,_end end
        ::continue::
    end
end
function M.filter_out_string(line,col,linenr,notree)
    local newline=''
    local string_pair={}
    local inpair={}
    local function in_pair(tbl,i)
        if inpair[tbl][i] then
            return inpair[tbl][i]
        end
        inpair[tbl][i]=tbl.fn.in_pair(line,i,{notree=notree,linenr=linenr}) or false
        return inpair[tbl][i]
    end
    for _,i in ipairs(default.filter_pair_type({'pairo','pair'})) do
        if i.conf.string then
            table.insert(string_pair,i)
            inpair[i]={}
        end
    end
    for i=1,#line do
        for _,v in ipairs(string_pair) do
            if in_pair(v,i) and in_pair(v,i+1) then
                newline=newline..'\1'
                goto continue
            end
        end
        newline=newline..line:sub(i,i)
        ::continue::
    end
    return newline,col
end
function M.filter_string(line,col,linenr,notree)
    local instring,strbeg,strend=M.instring(line,col,linenr,notree)
    if instring then
        return line:sub(strbeg+0,strend),col-strbeg+1
    end
    return M.filter_out_string(line,col,linenr,notree)
end
function M.call(m,ext)
    local check=m.check
    m.check=function (o)
        o.line,o.col=M.filter_string(o.line,o.col,o.linenr,ext.notree)
        return check(o)
    end
end
return M
