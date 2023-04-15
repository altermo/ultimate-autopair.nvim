local utils=require'ultimate-autopair.utils'
local default=require'ultimate-autopair.pair.default.utils.default'
local L={}
return {
    initialize=function (conf) --TODO: implement undo fly keymap
        return {
            check=function (o)
                if o.key==conf.undomap and L.incmd==o.incmd then
                    return L.back
                end
            end,
            get_map=default.get_map_wrapper(conf.undomap)
        }
    end,
    call=function (o,keyconf,conf,pair_type,m)
        if not keyconf.fly then return end
        if not (pair_type==2 or pair_type==3) then return end
        local next_char_index
        local line=conf.nofilter and o.wline or o.line
        local col=conf.nofilter and o.wcol or o.col
        if line:sub(col,col)==o.key then return end
        for i=col,#line do
            local char=line:sub(i,i)
            if vim.tbl_contains(conf.other_char,char)
                or vim.tbl_get(default.get_pair(char) or {},'conf','fly') then
                if char==o.key then
                    next_char_index=i
                    break
                end
            else
                return
            end
        end
        if not next_char_index then return end
        if m.fn.check_end_pair(m.start_pair,m.pair,line,col) then
            L.incmd=o.incmd
            L.back=utils.moveh(next_char_index-col)..m.pair
            return utils.movel(next_char_index-col+1)
        end
    end
}
