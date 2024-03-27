local M={}
local utils=require'ultimate-autopair.utils'
---@type table<string,true|table<string,boolean>>
M._cache_keywordy={}
function M.is_keywordy(char,o)
    if char=='\0' then return false end
    if M._cache_keywordy[char]==true then return true end
    local ft=utils.get_filetype(o)
    if not M._cache_keywordy[char] then M._cache_keywordy[char]={} end
    local is_keyword
    if ft==vim.o.filetype then
        is_keyword=vim.fn.charclass(char)==2
    else
        local opt_keyword=vim.o.iskeyword
        local opt_lisp=vim.o.lisp
        vim.o.iskeyword=utils.ft_get_option(ft,'iskeyword')
        vim.o.lisp=utils.ft_get_option(ft,'lisp')
        is_keyword=vim.fn.charclass(char)==2
        vim.o.lisp=opt_lisp
        vim.o.iskeyword=opt_keyword
    end
    M._cache_keywordy[char][ft]=is_keyword
    return is_keyword
end
---@param o ua.filter
---@return boolean?
function M.call(o)
    if o.conf.after then
        if M.is_keywordy(utils.get_char(o.line,o.cole),o) then
            return
        end
    end
    if o.conf.before then
        if o.conf.py_fstr and
            utils.get_filetype(o)=='python' and
            vim.regex[[\c\a\@1<!\v((r[fb])|([fb]r)|[frub])$]]:match_str(o.line:sub(1,o.cols-1)) then
            return true
        end
        if M.is_keywordy(utils.get_char(o.line,o.cols-1),o) then
            return
        end
    end
    return true
end
M.conf={
    before='boolean',
    after='boolean',
    py_fstr='boolean',
}
return M
