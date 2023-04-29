local utils=require'ultimate-autopair.utils'
local default=require'ultimate-autopair.configs.default.utils'
--TODO: implement undo fly keymap
return default.wrapp_old_extension(function (o,keyconf,conf,pair_type,m)
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
            return utils.movel(next_char_index-col+1)
        end
    end
)
