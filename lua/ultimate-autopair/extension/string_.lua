---F
local M={}
local default=require'ultimate-autopair.profile.default.utils'
local utils=require'ultimate-autopair.utils'
M.savetype={}
---@param o core.o
---@param nodetype string
---@return number?
---@return number?
---@return number?
---@return number?
function M._in_tsnode(o,nodetype)
    local node=utils.gettsnode(o)
    if not node then return end
    if node:parent() and node:parent():type()==nodetype then
        node=node:parent() --[[@as TSNode]]
    end
    if node:type()~=nodetype then return end
    local _,startcol,_=node:start()
    if startcol+1==o.col+o._coloffset(o.col,o.row) then return end
    local srow,scol,erow,ecol=utils.gettsnodepos(node,o)
    return scol+1,ecol,srow+1,erow+1
end
---@param o core.o
---@return {cache:table,currently_filtering:table?,[string]:any}
function M.get_save(o)
    local save=o.save[M.savetype]
    if not save then
        save={
            cache={},
        }
        o.save[M.savetype]=save
    end
    return save
end
---@param o core.o
---@param conf table
---@return number?
---@return number?
---@return number?
---@return number?
function M.instring(o,conf)
    ---TO_DO: cache
    ---TO_DO fix: '"|"' > "|" but should '"|"'
    ---TO_DO: a way of recursive string detection as "'" | "'", detected as in string '" | "'
    local save=M.get_save(o)
    for _,i in ipairs(conf.tsnode or {}) do
        local start,_end,startrow,endrow=M._in_tsnode(o,i)
        if start then
            return start,_end,startrow,endrow
        end
    end
    if conf.nopair then return end
    local currently_filtering=save.currently_filtering
    save.currently_filtering=save.currently_filtering or {}
    for _,i in ipairs(default.filter_for_opt({'pair'})) do
        ---@cast i prof.def.m.pair
        if not i.conf.string or not i.fn.in_pair then goto continue end
        if (currently_filtering or {})[i] then goto continue end
        save.currently_filtering[i]=true
        local start,_end,startrow,endrow=i.fn.in_pair(o,true)
        save.currently_filtering[i]=nil
        if start then
            save.currently_filtering=currently_filtering
            return start,_end,startrow,endrow
        end
        ::continue::
    end
end
---@param o core.o
---@param save table
---@param conf table
---@return boolean?
function M.filter(o,save,conf)
    if save.stringstart then
        return o.col>=save.stringstart and o.col<=save.stringend
            and o.row>=save.stringrowstart and o.row<=save.stringrowsend
    end
    local start,end_=M.instring(o,conf)
    if start and end_>o.col then
        return
    end
    return true
end
---@param m prof.def.module
---@param ext prof.def.ext
function M.call(m,ext)
    local check=m.check
    local conf=ext.conf
    m.check=function (o)
        local save=M.get_save(o)
        o.save[M.savetype]=save
        save.stringstart,save.stringend,save.stringrowstart,save.stringrowsend=M.instring(o,conf)
        return check(o)
    end
    local filter=m.filter
    m.filter=function(o)
        local save=M.get_save(o)
        if M.filter(o,save,conf) then
            return filter(o)
        end
    end
end
--in_pair=function (m,o,holeline)
    --if holeline then
        --if o.save[m.fn.in_pair]==nil then
            --o.save[m.fn.in_pair]=m.fn._in_pair_map(o)
        --end
        --if not o.save[m.fn.in_pair] then return end
        --return unpack(o.save[m.fn.in_pair][o.row][o.col] or {})
    --end
    --local opab,opabr=open_pair.open_pair_ambigous_before(m,o,o.col)
    --local opaa,opaar=open_pair.open_pair_ambigous_after(m,o,o.col)
    --if not (opaa and opab) then return end
    --return opab,opaa+#m.pair-1,opabr,opaar
--end,
--_in_pair_map=function (m,o)
    --local function match(str,line)
        --return str==line:sub(1,#str)
    --end
    --local single=not m.multiline
    --local sfilter=function(row,col_) return utils._filter_pos(m.start_m.filter,o,col_,row) end
    --local efilter=function(row,col_) return utils._filter_pos(m.end_m.filter,o,col_,row) end
    --local map={}
    --local flag
    --local spair=m.pair
    --local current=nil
    --for row,line in ipairs(o.lines) do
        --local i=1
        --map[row]={}
        --local ma=map[row]
        --while i<=#line do
            --local lline=line:sub(i)
            --if current then
                --ma[o.col]=current
            --else
                --ma[o.col]={}
            --end
            --if match(spair,lline) and
                --(current and sfilter(row,i) or
                --(not current and efilter(row,i)))
            --then
                --flag=true
                --if current then
                    --current[2]=i
                    --current[4]=row
                    --current=nil
                --else
                    --current={i,nil,row}
                --end
                --i=i+#spair
            --else
                --i=i+1
            --end
        --end
        --if single and current then
            --map[row]={}
        --end
    --end
    --if not single and current then
        --for k,_ in ipairs(map) do
            --map[k]={}
        --end
    --end
    --if not flag then
        --return false
    --end
    --return map
--end,
return M
