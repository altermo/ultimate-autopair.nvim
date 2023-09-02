local ua=require'ultimate-autopair'
local I={}
local M={I=I}
function I.opt(opt,conf)
    return function ()
        vim.o[opt]=conf
    end
end
function I.lazy(fn,...)
    local args={...}
    return function ()
        return fn(unpack(args))
    end
end
function I.lines(lines)
    return function ()
        local curpos
        for k,v in ipairs(lines) do
            if v:find('~') then
                curpos={k,v:find('~')}
                lines[k]=v:sub(0,v:find('~')-1)..v:sub(v:find('~')+1,-1)
                break
            end
        end
        vim.api.nvim_buf_set_lines(0,0,-1,false,lines)
        if curpos then
            vim.fn.cursor(curpos)
        end
    end
end
M.demo={}
M.demo.part_1={
    I.opt('filetype','lua'),
    I.lines{
        ' --normal + space (+ extension.fly)',
        ' --multiline support',
        '}}',
        '{{{{}} --prioritize close instead of skip',
        '"foo" --extenison.suround(surround) + backspace.overjump',
        'function bar() end --fastwarp + reverse-fastwarp',
        '--works in cmdline',
        ' "]" --string filter using treesitter',
        '{{{ --close + newline',
        '',
        '---Next features requires MANUAL enable',
        '',
        '{(foobar)baz} --tabout',
        '[  ]--space2',
    },
    .5,'i("{  }")',
    .1,'j',
    .5,'I{{{{',
    .1,'jj0llll',
    .5,'i}}}}',
    .1,'j',
    .5,'I((',
    .1,'j',
    .5,'I{',
    .1,'j',
    .5,'VV',
    .1,':"',
    .5,'({\r',
    .1,'j0',
    .5,'i[',
    .1,'j0ll',
    .5,'a\r',
    .1,'jjj',
    .5,'VV',
    .1,'jj0lllll',
    .5,'i',
    .1,'j0ll',
    .5,'afoo',
    vim.cmd.stopinsert,
}
function M.run_key(key,end_f)
    local map={
        ['']='<bs>',
        ['']='<A-e>',
        ['']='<A-E>',
        ['']='<A-)>',
        ['']='<A-tab>',
    }
    local pressed=(' '):rep(38)
    local it=vim.iter(vim.iter(key):fold({},function(t,v)
        if type(v)=="string" then
            for s in v:gmatch('.') do
                table.insert(t,s)
            end
        else
            table.insert(t,v)
        end
        return t
    end))
    local function async(time)
        if M._break then end_f() return end
        local v=it:next()
        if type(v)=='string' then
            vim.api.nvim_input(map[v] or v)
            vim.api.nvim_echo({{pressed},{'<'..v..'|'}},false,{})
            pressed=pressed:sub(2)..v
            vim.defer_fn(function () async(time) end,time*1000*(M._mul or 1))
        elseif type(v)=='number' then
            vim.schedule(function () async(v) end)
        elseif type(v)=='function' then
            v()
            vim.schedule(function () async(time) end)
        elseif v==nil then
            end_f()
        end
    end
    async(.1)
end
function M.run_keys(demo,end_f)
    M.run_key(demo,end_f)
end
function M.start()
    M._break=false
    if not vim.iter then
        vim.notify('This code requires `vim.iter` (neovim version 0.10.0)')
        return
    end
    local buf=vim.api.nvim_create_buf(true,true)
    vim.api.nvim_set_option_value('bufhidden','wipe',{buf=buf})
    vim.cmd('tab split')
    vim.cmd.buffer(buf)
    vim.keymap.set({'i','n','x'},'<C-c>',function() M._break=true end,{buffer=buf})
    M.save()
    vim.wo.number=false
    vim.wo.relativenumber=false
    vim.wo.cursorline=false
    vim.wo.colorcolumn=''
    vim.wo.signcolumn='no'
    vim.o.laststatus=0
    vim.o.showtabline=0
    vim.o.cmdheight=1
    vim.o.ruler=false
    vim.cmd.redraw()
    vim.fn.input('Press enter to start (hold <C-c> to stop)...')
    ua.setup{
        tabout={enable=true},
        space2={enable=true},
    }
    pcall(M.run_keys,M.demo.part_1,function() M.restore() end)
end
function M.save()
    M._save={
        conf=ua._configs,
        laststatus=vim.o.laststatus,
        showtabline=vim.o.showtabline,
        cmdheight=vim.o.cmdheight,
        ruler=vim.o.ruler
    }
end
function M.restore()
    ua.init(M._save.conf)
    vim.o.laststatus=M._save.laststatus
    vim.o.showtabline=M._save.showtabline
    vim.o.cmdheight=M._save.cmdheight
    vim.o.ruler=M._save.ruler
end
M.start()
return M
