local utils=require'ultimate-autopair.utils'
local open_pair=require'ultimate-autopair._lib.open_pair' --TODO:make user be able to chose the open_pair detector (separately for open_pair/find_pair/...)
local putils=require'ultimate-autopair.profile.pair.utils'
local M={}
---@param o ua.info
---@return ua.actions|nil
function M.run_start(o)
    o._lsave={} --TODO: temp
    local info=(o.m --[[@as ua.prof.def.pair]]).info
    local last_char=info.start_pair:sub(-1+vim.str_utf_start(info.start_pair,#info.start_pair))
    local ret=putils.run_extension(info.extension,o)
    if ret then return ret end
    if o.line:sub(o.col-#info.start_pair+#last_char,o.col-1)~=info.start_pair:sub(0,-1-#last_char) then return end
    if not utils.run_filters(info.start_pair_filter,o,#info.start_pair-1) then
        return
    end
    if info.start_pair~=info.end_pair then
        local count=open_pair.count_end_pair(o)
        if open_pair.count_end_pair(o,true,count,true) then return end
    else
        if open_pair.count_ambiguous_pair(o,'both') then return end
    end
    return {
        last_char,
        info.end_pair,
        {'left',info.end_pair},
    }
end

---@param o ua.info
---@return ua.actions|nil
function M.run_end(o)
    o._lsave={} --TODO: temp
    local info=(o.m --[[@as ua.prof.def.pair]]).info
    local ret=putils.run_extension(info.extension,o)
    if ret then return ret end
    if o.line:sub(o.col,o.col+#info.end_pair-1)~=info.end_pair then return end
    if not utils.run_filters(info.end_pair_filter,o,0,-#info.end_pair) then
        return
    end
    if info.start_pair~=info.end_pair then
        local count2=open_pair.count_start_pair(o)
        --Same as: count_open_end_pair_after
        local count1=open_pair.count_end_pair(o)
        --Same as: count_open_start_pair_before
        if count1==0 or count1>count2 then return end
    else
        if open_pair.count_ambiguous_pair(o,'both') then return end
    end
    return {
        {'right',info.end_pair},
    }
end
---@param pair ua.prof.pair.conf.pair
---@return ua.prof.def.pair[]
function M.init(pair)
    ---TODO: pair may include hook options, so follow that
    local start_pair=pair[1]
    local end_pair=pair[2]

    local info_mt={
        extension=pair.extension,
        start_pair=start_pair,
        end_pair=end_pair,
        multiline=pair.multiline,
        _filter={ --TODO:TEMP
            start_pair_filter=function (o)
                return utils.run_filters(pair.start_pair_filter,o,#start_pair-1,-1)
            end,
            end_pair_filter=function (o)
                return utils.run_filters(pair.end_pair_filter,o,#end_pair-1,-1)
            end
        },
        end_pair_filter=pair.end_pair_filter,
        start_pair_filter=pair.start_pair_filter,
    }
    return {
        {
            run=M.run_end,
            info=setmetatable({main_pair=end_pair,type='end'},{__index=info_mt}),
            hooks=putils.create_hooks(end_pair:sub(1,vim.str_utf_end(end_pair,1)+1),pair.map_modes),
            doc=('autopairs end pair: %s,%s'):format(start_pair,end_pair),
        },
        {
            run=M.run_start,
            info=setmetatable({main_pair=start_pair,type='start'},{__index=info_mt}),
            hooks=putils.create_hooks(start_pair:sub(vim.str_utf_start(start_pair,#start_pair)+#start_pair),pair.map_modes),
            doc=('autopairs start pair: %s,%s'):format(start_pair,end_pair)
        }
    }
end
return M
