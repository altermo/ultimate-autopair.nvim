---@class ua.check.handler
---@field ok fun(msg:string)
---@field info fun(msg:string)
---@field warn fun(msg:string)
---@field error fun(msg:string)
---@field start fun(msg:string)

local M={}
M.health_handler={
    ok=vim.health.ok or vim.health.report_ok,
    info=vim.health.info or vim.health.report_info,
    warn=vim.health.warn or vim.health.report_warn,
    error=vim.health.error or vim.health.report_error,
    start=vim.health.start or vim.health.report_start,
}
M.default_handler={
    ok=function (msg) vim.notify('Ok: '..msg) end,
    info=function (msg) vim.notify('Info: '..msg) end,
    warn=function (msg) vim.notify('Warn: '..msg) end,
    error=function (msg) vim.notify('Error: '..msg) end,
    start=function (_) end,
}

---@param name 'user'|'default'
local function validate_config(handler,name)
    local config=require'ultimate-autopair.config'
    local ua=require'ultimate-autopair'
    handler.start('Validating '..name..' config')
    local default=ua.get_default_config()
    local noerr,msg
    if name=='user' then
        local conf=ua.get_config()
        local validate=conf.validate
        if not validate then validate=true end
        noerr,msg=pcall(config, conf,default,validate)
    elseif name=='default' then
        noerr,msg=pcall(config, default,nil,math.huge)
    end
    if noerr then
        handler.ok(name:sub(1,1):upper()..name:sub(2)..' config is valid')
    else
        handler.error(name:sub(1,1):upper()..name:sub(2)..' config is invalid:'..msg)
    end
end
local function validate_externals(handler)
    handler.start('External (optional) plugins')
    if not pcall(require,'nvim-treesitter') then
        handler.warn('nvim-treesitter not found')
        handler.info('NOTE: nvim-treesitter is not required if parsers are installed through other ways')
    else
        handler.ok('nvim-treesitter found')
    end
    if not pcall(require,'nvim-treesitter-endwise') then
    else
        error('TODO')
    end
end
local function check_not_allowed_string_and_typos(handler,lua_path,plugin_path)
    local jobs={}
    local jobsdata={}
    if vim.fn.executable('grep')==1 then
        local blacklist={'vim.lg','print','vim.dev','vim.tbl_contains','vim.list_contains'}
        local search=table.concat(blacklist,'\\|')
        local flag=false
        local job=vim.fn.jobstart({'grep','-r','--exclude=health.lua',search,lua_path},{on_stdout=function (_,data,_)
            for _,v in ipairs(data) do
                if v~='' then
                    if not flag then
                        handler.warn('The following strings are not allowed: `'..table.concat(blacklist,'`, `')..'`')
                        handler.info('INFO Replace any `vim.tbl_contains` and `vim.list_contains` with `utils.in_list`')
                        flag=true
                    end
                    handler.warn('Found something not allowed (using grep): '..v:sub(v:sub(2):find(' ') or 1))
                end
            end
        end})
        table.insert(jobs,job)
        table.insert(jobsdata,{name='grep',expected=1})
    else
        handler.warn('`grep` not found, skipping checks which require it')
    end
    if vim.fn.executable('typos')==1 then
        local job=vim.fn.jobstart({'typos'},{cwd=plugin_path,on_stdout=function(_,data,_)
            for _,v in ipairs(data) do
                if v~='' then
                    handler.warn(v)
                end
            end
        end})
        table.insert(jobs,job)
        table.insert(jobsdata,{name='typos',expected=0})
    else
        handler.warn('`typos`(https://github.com/crate-ci/typos) not found, skipping checks which require it')
    end
    for k,job in ipairs(jobs) do
        local exitcode=vim.fn.jobwait({job},5000)[1]
        local mt=jobsdata[k]
        if exitcode==-1 then
            handler.warn(('timeout `%s`'):format(mt.name))
        elseif exitcode~=(mt.expected or 0) then
            handler.warn(('job `%s` exited with code %s'):format(mt.name,exitcode))
        end
    end
end
local function check_unique_lang_to_ft(handler)
    local tree_langs=vim.tbl_map(function (x)
        return vim.fn.fnamemodify(x,':t:r')
    end,vim.api.nvim_get_runtime_file('parser/*',true))
    local done=vim.deepcopy(require'ultimate-autopair.utils'.tslang2lang)
    for _,tree_lang in ipairs(tree_langs) do
        local single
        if done[tree_lang]=='' then goto continue end
        vim.treesitter.language.add(tree_lang)
        local filetypes=vim.treesitter.language.get_filetypes(tree_lang)
        local ft=done[tree_lang]
        if type(ft)=='table' then
            ft=ft[1]
            single=true
        end

        if done[tree_lang] then
            if not vim.tbl_contains(filetypes,ft) and not single then
                handler.warn(('filetype `%s` in `utils.tslang2lang["%s"]` may be incorrect'):format(ft,tree_lang))
            end
        elseif #filetypes>1 then
            handler.warn('Found multiple languages for '..tree_lang..': '..vim.inspect(filetypes))
        end
        done[tree_lang]=''
        ::continue::
    end
    for k,v in pairs(done) do
        if v~='' then
            handler.warn('filetype '..k..' in utils.tslang2lang['..v..'] can be removed')
        end
    end
end
local function check_other(handler)
    local default=require'ultimate-autopair.default_configs'
    local nodes={}
    vim.list_extend(nodes,default._default_comment_nodes)
    vim.list_extend(nodes,default._default_stringish_nodes)
    table.sort(nodes)
    local nodes_2=vim.tbl_values(default._default_comment_and_stringish_nodes)
    table.sort(nodes_2)
    if not vim.deep_equal(nodes,nodes_2) then
        handler.warn('In default.lua, content of comment and stringish does not match comment_and_stringish')
    end
end
local function run_tests(handler,plugin_path)
    package.loaded['ultimate-autopair.test']=nil
    local test=require'ultimate-autopair.test'
    test.run_tests(plugin_path,handler)
end

function M.check()
    M.start(true,M.health_handler)
end
function M.start(dev,handler)
    handler=handler or M.default_handler
    local lua_path=vim.api.nvim_get_runtime_file('lua/ultimate-autopair',false)[1]
    if not lua_path then
        handler.error('Could not find ultimate-autopair plugin path')
        return
    end
    if vim.fn.has('nvim-0.9.2')~=1 then
        handler.error('Your neovim version is not supported (please use 0.9.2 or newer)')
        return
    end
    if dev then
        handler.info('Development chesks are enabled')
    end
    local plugin_path=vim.fs.dirname(vim.fs.dirname(lua_path))
    if not dev then
        validate_config(handler,'user')
        validate_externals(handler)
        return
    end
    validate_config(handler,'user')
    validate_config(handler,'default')
    validate_externals(handler)
    handler.start('Development checks')
    check_not_allowed_string_and_typos(handler,lua_path,plugin_path)
    check_unique_lang_to_ft(handler)
    check_other(handler)
    run_tests(handler,plugin_path)
end
return M
