---@type table<string,ua.check.test[]>
local list_of_tests={
    simple={
        {'|','(','(|)'},
        {'|)','(','(|)'},
        {'(|)','(','((|))'},
        {'(|','(','((|)'},
        {'|)(','(','(|)('},
        {'() |','(','() (|)'},
        {'(|))','(','((|))'},

        {'(|)',')','()|'},
        {'((|))',')','(()|)'},
        {'|)',')',')|)'},
        {'(|))',')','()|)'},
        {'()|)',')','())|)'},

        {'|','"','"|"'},
        {'"|"','"','""|'},
        {'|"','"','"|"'},
        {'"|','"','""|'},
        {"'' |","'","'' '|'"},
        {'"a|b"','"','"a"|"b"'},

        {'|','f(','foo(|)',cmd='abbr <buffer>f foo'},

        --{'((|))','<lt>','((<|>))',{{'((<','>))'}}},
        --{'|','*','*|*',{{'*','*'},{'**','**'}}},
        --{'*|*','*','**|**',{{'*','*'},{'**','**'}}},
        --{'*|*','*','**|**',{{'**','**'}}},
        --{'**|**','*','***|***',{{'**','**'},{'***','***'}}},
        --{'**|**','*','***|***',{{'***','***'}}},
        --{'**|**','*','****|',{{'*','*'},{'**','**'}}},
        --{'*|**','*','**|**',{{'*','*'},{'**','**'}}},
        --{'**|*','*','***|*',{{'*','*'},{'**','**'}}},
        --{'****|','*','*****|*',{{'*','*'},{'**','**'}}},
        --{'***|*','*','****|*',{{'**','**'}}},
        --{'|','{','{|},',{c={{'{','},'}}}},
        --{'""|""','"','"""|"""'},
        --{'"|""','"','""|""'},
        --{'""|"','"','"""|"'},

        {'|','<esc>a(<esc>..a','(((|)))'},
        {'|','<esc>3a(<esc>a','(((|)))'},
        {'|foo','<esc>R(','(|)o'},

        --{'<!-|','-','<!--|'},
        --{'<!-|','-','<!--|-->',{ft='markdown'}},
        --{'<!-|-->','-','<!--|-->',{ft='markdown'}},
        --{'<!--|-->','-','<!---->|',{ft='markdown'}},
        --{'""|','"','"""|"""',{ft='python'}},
        --{'"""|"""','"','""""""|',{ft='python'}},

        {'<cr|','>','<cr>|<cr>',{{'<cr>','<cr>'}}},
        {'\0|\0',"'","\0'|'\0"},

        --{'(|)',')','()|)',{change={{'(',{'',')'}}}}},
        --{'|','(','(|)',{change={{{'(','('},{'',')'}}}}},
        --{'|','(','(|',{change={{{'','('},')'}}}},
        --{'(|)',')','()|',{change={{{'','('},')'}}}},
        --{'|','"','"|',{change={{{'','"'},'"'}}}},
        --{'"|"','"','""|""',{change={{'"',{'','"'}}}}},
    },
    modes={
        {'|','<C-r>="(\r','()|'},
        --{'|','&','&|',{{'&','?',map_modes={'c'}}}},


        {'|','<esc>:lua vim.api.nvim_open_term(0,{on_input=function (_,chan,_,i) vim.api.nvim_chan_send(chan,i) end}) vim.uv.run()\ri(','(|)',{map_modes={'t'}},trim=true},
    },
    multiline={
        {'|\n)','(','(|\n)'},
        {'(|\n)','(','((|)\n)'},
        {'(\n|\n)','(','(\n(|)\n)'},
        {'(|\n))','(','((|\n))'},
        {'|\n>','<lt>','<|>\n>',{{'<','>',multiline=false}}},

        {'(\n|)',')','(\n)|'},
        {'\n|)',')','\n)|)'},
        {'()\n|)',')','()\n)|)'},
        {'(\n(|)',')','(\n()|)'},
        {'<\n|>','>','<\n>|>',{{'<','>',multiline=false}}},
        {'<|>\n','>','<>|\n',{{'<','>',multiline=false}}},

        {'"\n|','"','"\n"|"'},
        --{'"\n|','"','"\n"|"',{change={{'"','"',multiline=true}}}},
        {'*\n|*','*','*\n*|',{{'*','*',multiline=true}}},
        {'*\n|*','*','*\n*|*',{{'*','*',multiline=false}}},

        {'|','f\r','foo\n|',cmd='abbr <buffer>f foo'},
    },
}

---@class ua.check.test
---@field [1] string
---@field [2] string
---@field [3] string
---@field [4] table?
---@field I any

---@class ua.check.chan
---@field handler ua.check.handler
---@field _chan number
---@field request fun(...:any):any
---@field exec fun(cmd:string):string
---@field exec_lua fun(cmd:string)

---@param handler ua.check.handler
---@return ua.check.chan
local function create_chan(handler)
    ---@type ua.check.chan
    local chan={} --[[@as unknown]]
    chan.handler=handler
    chan._chan=vim.fn.jobstart({vim.v.progpath,'--embed','--headless','--clean'},{rpc=true})
    vim.schedule(function ()
        pcall(vim.fn.jobstop, chan._chan)
    end)

    function chan.request(...)
        return vim.rpcrequest(chan._chan,...)
    end
    function chan.exec(cmd)
        return chan.request('nvim_exec2',cmd,{output=true}).output
    end
    function chan.exec_lua(cmd)
        return chan.request('nvim_exec_lua',cmd,{})
    end
    return chan
end
local function validate_test(test)
    assert(type(test[1])=='string')
    assert(test[1]:find('|'))
    assert(type(test[2])=='string')
    assert(not test[2]:find('|'))
    assert(type(test[3])=='string')
    assert(test[3]:find('|'))
    assert(test[4]==nil or type(test[4])=='table')
end
local get_tests_by_config=function ()
    local config_to_tests={}
    for category,tests in pairs(list_of_tests) do
        for index,test in pairs(tests) do
            validate_test(test)
            local conf=test[4] or {}
            if test.I then
                return {[conf]={[category]={[index]=test}}}
            end
            for config,_ in pairs(config_to_tests) do
                if vim.deep_equal(conf,config) then
                    config_to_tests[config][category][index]=test
                    goto continue
                end
            end
            config_to_tests[conf]=vim.defaulttable(function () return {} end)
            config_to_tests[conf][category][index]=test
            ::continue::
        end
    end
    return config_to_tests
end
local function set_lines_and_pos(chan,lines)
    lines=vim.split(lines,'\n')
    local row,col
    for k,v in ipairs(lines) do
        col=v:find('|',1,true)
        if col then row=k break end
    end
    assert(row)
    lines[row]=lines[row]:sub(0,col-1)..lines[row]:sub(col+1)
    chan.request('nvim_buf_set_lines',0,0,-1,true,lines)
    chan.request('nvim_win_set_cursor',0,{row,col-1})
end
local function feed(chan,input)
    if chan.request('nvim_input',input)~=#input then return false end
    local errmsg=chan.request('nvim_get_vvar','errmsg')
    if errmsg~='' then chan.exec('let v:errmsg=""') end
    return errmsg
end
local function create_backtrace(test,actual)
    local ret=('{Initial}:\n%s\n{Input}: `%s`\n{Expected-result}:\n%s'):format(test[1],test[2],test[3])
    if actual then ret=ret..('\n{Actual-result}:\n%s'):format(actual) end
    if next(test,next(test,next(test,next(test)))) then
        test[1]=nil
        test[2]=nil
        test[3]=nil
        ret=('{Config}:\n%s\n'):format(vim.inspect(test))..ret
    end
    return ret
end
local function get_lines_and_pos(chan,trim)
    local lines=chan.request('nvim_buf_get_lines',0,0,-1,true)
    local row,col=unpack(chan.request('nvim_win_get_cursor',0))
    lines[row]=lines[row]:sub(1,col)..('|')..lines[row]:sub(col+1)
    local line=table.concat(lines,'\n')
    if trim then
        line=vim.trim(line)
    end
    return line
end
local function run_tests(chan,ctests)
    local loaded_config=false
    for category,tests in pairs(ctests) do
        for index,test in pairs(tests) do
            if not loaded_config then
                chan.exec_lua(([[
                local ua_conf=require'ultimate-autopair.test'.tests.%s[%d][4]
                require'ultimate-autopair'.setup(ua_conf)
                ]]):format(category,index))
                loaded_config=true
            end
            chan.exec('stopinsert')
            chan.exec('bwipeout!')
            chan.exec('edit '..vim.fn.tempname())
            chan.exec('set all&')
            chan.exec('startinsert')
            if test.ft then
                chan.exec(':setf '..test.ft)
                chan.exec_lua('pcall(vim.treesitter.start)')
            end
            if test.cmd then
                chan.exec(test.cmd)
            end
            set_lines_and_pos(chan,test[1])
            local errmsg=feed(chan,test[2])
            if errmsg==false then
                local msg=('test(%s) went wrong:\nThe input could not be processed\nPossible reason: An unmatched `<` may be in the input, replace all unmatched `<` with `<lt>`\n%s'):format(category,create_backtrace(test))
                chan.handler.error(msg)
            elseif errmsg~='' then
                local msg=('test(%s) errord:\n%s\n%s'):format(category,errmsg,create_backtrace(test))
                chan.handler.error(msg)
                -- When a test errors, it is slow, and one errord test typically means multiple errord tests
                -- So we don't stop test execution here so that the test execution doesn't take so long
                return 'error'
            elseif get_lines_and_pos(chan,test.trim)~=test[3] then
                local msg=('test(%s) failed\n%s'):format(category,create_backtrace(test,get_lines_and_pos(chan)))
                chan.handler.error(msg)
            end
        end
    end
end
local M={}
M.tests=list_of_tests
---@param plugin_path string?
---@param handler ua.check.handler?
function M.run_tests(plugin_path,handler)
    handler=handler or require'ultimate-autopair.health'.default_handler
    handler.start('Running tests')
    if not plugin_path then
        local lua_path=vim.api.nvim_get_runtime_file('lua/ultimate-autopair',false)[1]
        if not lua_path then
            handler.error('Could not find ultimate-autopair plugin path')
            return
        end
        plugin_path=vim.fs.dirname(vim.fs.dirname(lua_path))
    end

    if vim.fn.executable(vim.v.progpath)==0 then
        handler.error('Could not find executable nvim')
        return
    end
    if (vim.fn.systemlist({vim.v.progpath,'--version'})[1]~=vim.api.nvim_exec2('version',{output=true}).output:gsub('^\n(.-)\n.*','%1')) then
        handler.warn(("The version number in `:version` didn't match `:!%s --version`"):format(vim.v.progpath))
    end

    local chan=create_chan(handler)
    chan.exec('set runtimepath+='..plugin_path)
    chan.exec_lua[[
    vim['lg']=function (...)
        local d=debug.getinfo(2)
        return vim.fn.writefile(vim.fn.split(
            ':'..d.short_src..':'..d.currentline..':\n'..
            vim.inspect(#{...}==1 and ... or {...}),'\n'
        ),'/tmp/nlog','a')
    end]]

    local conf_tests=get_tests_by_config()
    for _,tests in pairs(conf_tests) do
        if run_tests(chan,tests)=='error' then
            handler.warn('Unrecoverable error happened: Prematurely stopping test execution')
            break
        end
    end
    if vim.fn.jobstop(chan._chan)==0 then
        handler.error('Could not stop test execution')
    end
end
return M
