local M={}
local utils=require'ultimate-autopair.utils'
function M.space()
    if not vim.regex([[\a]]):match_str(vim.v.char) then return end
    local space=utils.getline():sub(1,utils.getcol()-1):reverse():match(' *')
    local keys=space..vim.keycode('<Left>'):rep(#space)
    vim.api.nvim_feedkeys(keys,'n',true)
end
function M.setup()
    if M.au_id then
        vim.api.nvim_del_autocmd(M.au_id)
    end
    M.au_id=vim.api.nvim_create_autocmd('InsertCharPre',{callback=M.space})
end
return M
