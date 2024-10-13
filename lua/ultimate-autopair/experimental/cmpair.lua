local utils=require'ultimate-autopair.utils'
---@class prof.cmpair.module:core.module
---@class prof.cmpair.opt:prof.mconf

local M={}
function M.open_end_pair_after(line,col,pairs,paire)
    local idx=0
    local count=0
    for c in line:gmatch('.') do
        idx=idx+1
        if c==pairs then
            count=count+1
        elseif c==paire then
            count=count-1
            if count<0 then
                if idx>=col then return true end
                count=0
            end
        end
    end
end
function M.on_confirm_done(ev,conf)
    local cmp=require'cmp'
    if ev.commit_character then
        return
    end
    local entry=ev.entry
    local item=entry:get_completion_item()
    local opts=conf[entry.context.filetype] or conf[entry.source.name] or conf['*']
    if opts==false then return end
    if opts==nil or opts=='auto' then
        opts={['(']={')',kind={'Function','Method'},lisp=vim.bo.lisp}}
        if entry.context.filetype=='python' and item.data then
            item.data.funcParensDisabled=false
        end
    end
    if (item.data and type(item.data)=='table' and item.data.funcParensDisabled)
        or (item.textEdit and item.textEdit.newText and item.textEdit.newText:find('[[($]'))
        or (item.insertText and item.insertText:find('[[($]'))
    then
        return
    end
    local line=utils.getline()
    local col=utils.getcol()
    local before_char=line:sub(col-1,col-1)
    local after_char=line:sub(col,col)
    for char,opt in pairs(opts) do
        if vim.tbl_contains(opt.kind,cmp.lsp.CompletionItemKind[item.kind]) and
            (char~=before_char) and (char~=after_char)
        then
            if opt.lisp then
                if line:sub(col-1-#item.label,col-1-#item.label)=='(' then
                    vim.api.nvim_feedkeys(' ','n',false)
                    return
                end
                vim.api.nvim_feedkeys(utils.create_act({
                    {'h',#item.label},
                    '(',
                    {'l',#item.label},
                    ' )',
                    {'h'},
                }),'n',false)
                return
            end
            if not M.open_end_pair_after(line,col-1,char,opt[1]) then
                vim.api.nvim_feedkeys(utils.create_act({'()',{'h'}}),'n',false)
                return
            end
        end
    end
end
---@param conf prof.cmpair.opt
function M.init_cmp(conf)
    local cmp=require'cmp'
    return cmp.event:on(
        'confirm_done',
        function (ev)
            M.on_confirm_done(ev,conf)
        end
    )
end
---@param conf prof.cmpair.opt
---@param mem core.module[]
function M.init(conf,mem)
    ---@type prof.cmpair.module
    local m={}
    m.p=conf.p or 10
    m.doc='autopairs cmp-pair'
    local off
    m.oinit=function (delete)
        if off then off() off=nil end
        if delete then return end
        off=M.init_cmp(conf)
    end
    table.insert(mem,m)
end
return M
