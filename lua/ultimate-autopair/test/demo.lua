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
    .5,
    I.lines{
        ' --normal',
        '{{{{}} --prioritize close instead of skip',
        '--[[',
        ' --multiline support',
        '}}',
        '--]]'
    },
    'i("{  }")',
    .1,
    'j0lll',
    .5,
    'i}}}}',
    .1,
    'jj0',
    .5,
    'i{{{{',
    vim.cmd.stopinsert,
}
function M.run_key(key,end_f)
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
        if M.brea then return end
        local v=it:next()
        if type(v)=='string' then
            vim.api.nvim_input(v)
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
    M.brea=false
    if not vim.iter then
        vim.notify('This code requires `vim.iter` (neovim version 0.10.0)')
        return
    end
    local buf=vim.api.nvim_create_buf(true,true)
    vim.api.nvim_set_option_value('bufhidden','wipe',{buf=buf})
    vim.cmd('tab split')
    vim.cmd.buffer(buf)
    vim.o.showtabline=0
    vim.keymap.set('i','<C-h>','<bs>',{noremap=false,buffer=true})
    vim.keymap.set('i','<C-e>','<A-e>',{noremap=false,buffer=true})
    vim.keymap.set({'i','n','x'},'<C-c>',function() M.brea=true end,{buffer=true})
    vim.cmd.redraw()
    vim.fn.input('Press enter to start (hold <C-c> to stop)...')
    local old_conf=ua._configs
    ua.setup()
    pcall(M.run_keys,M.demo.part_1,function() ua.init(old_conf) end)
end
M.start()
return M
