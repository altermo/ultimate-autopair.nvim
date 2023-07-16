local M={}
local default=require'ultimate-autopair.configs.default.utils'
function M.instring(line,col,linenr,notree,wcol)
    for _,i in ipairs(default.filter_pair_type({'pairo','pair'})) do
        if not i.conf.string or not i.fn.in_pair then goto continue end
        local isin,start,_end=i.fn.in_pair(line,col,{notree=notree,linenr=linenr,wcol=wcol})
        if isin then return isin, start,_end end
        ::continue::
    end
end
function M.filter_out_string(line,col,linenr,notree,wcol)
    local newline=''
    local string_pair={}
    local inpair={}
    local function in_pair(tbl,i)
        if inpair[tbl][i]~=nil then
            return inpair[tbl][i]
        end
        if tbl.fn.in_pair_map then
            inpair[tbl]=tbl.fn.in_pair_map(line,{notree=notree,linenr=linenr,wcol=wcol})
            return inpair[tbl][i]
        end
        inpair[tbl][i]=tbl.fn.in_pair(line,i,{notree=notree,linenr=linenr,wcol=wcol}) or false
        return inpair[tbl][i]
    end
    for _,i in ipairs(default.filter_pair_type({'pairo','pair'})) do
        if i.conf.string and i.fn.in_pair then
            table.insert(string_pair,i)
            inpair[i]={}
        end
    end
    for i=1,#line do
        if line:sub(i,i)=='\1' then
            newline=newline..'\1'
            goto continue
        end
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
function M.filter_string(line,col,linenr,notree,wcol)
    local instring,strbeg,strend=M.instring(line,col,linenr,notree,wcol)
    if instring then
        return line:sub(strbeg+0,strend),col-strbeg+1
    end
    return M.filter_out_string(line,col,linenr,notree,wcol)
end
function M.call(m,ext)
    local check=m.check
    m.check=function (o)
        o.line,o.col=M.filter_string(o.line,o.col,o.linenr,ext.notree,o.wcol)
        return check(o)
    end
end
return M
