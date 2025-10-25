local utils=require'ultimate-autopair.utils'
---@param con ua.context
---@param range Range4
---@param after boolean
---@param chars string|true
---@return boolean
local function is_keywordy(con,range,after,chars)
    local char
    if after then
        char=utils.chars_after_range(con,range,1)
    else
        char=utils.chars_before_range(con,range,1)
    end
    if char=='\0' then
        return false
    elseif type(chars)=='string' then
        return chars:find(char,1,true) and true or false
    end
    local ft=utils.get_filetype(con,range)

    -- not `con.root_filetype` because of cmdline
    if ft==vim.o.filetype then
        return vim.fn.charclass(char)==2
    end
    return utils.with({o={
        iskeyword=utils.ft_get_opt(con,ft,'iskeyword'),
        lisp=utils.ft_get_opt(con,ft,'lisp'),
    }},function ()
            return vim.fn.charclass(char)==2
        end)
end
---@param conf ua.config.filter.alpha
return function (conf)
    ---@type ua.config.filter.spec
    return {
        pos=function (con,range)
            if conf.after then
                if is_keywordy(con,range,true,conf.after) then
                    return true
                end
            end
            if conf.before then
                if conf.fstring_smart and
                    utils.get_filetype(con,range)=='python' and
                    vim.regex[[\c\a\@1<!\v((r[fb])|([fb]r)|[frub])$]]:match_str(
                        utils.chars_before_range(con,range,2)
                    ) then
                    return
                end
                if is_keywordy(con,range,false,conf.before) then
                    return true
                end
            end
        end,
        _name='alpha',_conf=conf,

        filter=conf.filter,
        filter_or=conf.filter_or,
        singlechar=conf.singlechar,
    }
end
