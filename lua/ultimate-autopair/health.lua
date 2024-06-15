local M={}
local ok=vim.health.ok or vim.health.report_ok
local info=vim.health.info or vim.health.report_info
local warn=vim.health.warn or vim.health.report_warn
local error=vim.health.error or vim.health.report_error
local start=vim.health.start or vim.health.report_start
function M.check()
    M.start()
end
function M.validate_config()
    start('Configuration is valid')
    local confspec=require'ultimate-autopair.profile.pair.confspec'
    local configs,is_setup=require'ultimate-autopair'['~get_configs']()
    for _,config in ipairs(configs or {}) do
            if config.profile=='pair' or not config.profile then
            confspec.validate(config,'main')
            if is_setup and _G.UA_DEV then
                local s,err=pcall(confspec.validate,require'ultimate-autopair'.extend_default(config),'main')
                if not s and err then
                    error('Config after merging with default config is invalid:')
                    info(err)
                end
            end
        end
    end
    ok('User configuration is valid')
    if _G.UA_DEV then
        local s,err=pcall(confspec.validate,require'ultimate-autopair.default'.conf,'main')
        if not s and err then
            error('Default configuration is invalid:')
            info(err)
        end
        s,err=pcall(confspec.validate,confspec.generate_random('main'),'main')
        if not s and err then
            error('Randomly generated configuration is invalid')
            info(err)
        end
        s,err=pcall(confspec.validate,confspec.inherit(require'ultimate-autopair.default'.conf),'main')
        if not s and err then
            error('Default configuration after inheritance is invalid:')
            info(err)
        end
    end
end
function M.validate_externals()
    start('External (optional) plugins')
    if not pcall(require,'nvim-treesitter') then
        warn('nvim-treesitter not found')
        info('NOTE: nvim-treesitter is not required if parsers are installed through other ways')
    else
        ok('nvim-treesitter found')
    end
    if not pcall(require,'nvim-treesitter-endwise') then
    else
        local int=require'ultimate-autopair.integration.endwise'
        local err
        local pack=package.loaded['nvim-treesitter.endwise']
        local on_key=vim.on_key
        pcall(function ()
            local t={}
            on_key=function (fn)
                table.insert(t,fn)
            end
            package.loaded['nvim-treesitter.endwise']=nil
            require'nvim-treesitter.endwise'
            err=int.extract_function()
        end)
        vim.on_key=on_key
        package.loaded['nvim-treesitter.endwise']=pack
        if type(err)=='string' or not err then
            warn('nvim-treesitter-endwise found, but could not extract endwise function')
            info('This is probably because you are using a different version than supported')
            info('NOTE This does not impact normal usage of endwise, only some edge cases')
            info('The problem: '..(err or 'unknown error'))
        else
            ok('nvim-treesitter-endwise found: changing newline to not break endwise')
        end
    end
    if not pcall(require,'nvim-ts-autotag') then
        warn('nvim-ts-autotag not found: autotag integration will not work')
    else
        ok('nvim-ts-autotag found: autotag integration will work')
    end
end
function M.start()
    local lua_path=vim.api.nvim_get_runtime_file('lua/ultimate-autopair',false)[1]
    if not lua_path then
        error('Could not find ultimate-autopair plugin path')
        return
    end
    if vim.fn.has('nvim-0.9.2')==0 then
        error('Your neovim version is not supported (please use 0.9.2 or newer)')
    end
    local plugin_path=vim.fn.fnamemodify(lua_path,':h:h')
    M.validate_config()
    M.validate_externals()
    if _G.UA_DEV then
        M.start_dev(plugin_path,lua_path)
    end
end
function M.run_tests(plugin_path)
    package.loaded['ultimate-autopair.test.tests']=nil
    package.loaded['ultimate-autopair.test']=nil
    local test=require'ultimate-autopair.test'
    test.ok=ok
    test.error=error
    test.warning=warn
    test.info=info
    test.test(plugin_path)
end
function M.check_not_allowed_string(path)
    if vim.fn.executable('grep')==0 then
        warn('Some of the required executables are missing for dev testing')
        info('INFO Please make sure that `grep` is installed')
        return
    end
    local blacklist={'vim.lg','print','vim.dev','vim.tbl_contains','vim.list_contains'}
    local search=table.concat(blacklist,'\\|')
    local job=vim.fn.jobstart({'grep','-r','--exclude=health.lua','--exclude-dir=test',search,path},{on_stdout=function (_,data,_)
        for _,v in ipairs(data) do
            if v=='' then return end
            warn('Found something not allowed: '..v:sub(v:sub(2):find(' ') or 1))
        end
    end})
    debug.setmetatable(job,{name='grep',expected=1})
    local jobs={job}
    for k,exitcode in ipairs(vim.fn.jobwait(jobs,5000)) do
        local mt=getmetatable(jobs[k])
        if exitcode==-1 then
            warn(('timeout `%s`'):format(mt.name))
        elseif exitcode~=(mt.expected or 0) then
            warn(('job `%s` exited with code %s'):format(mt.name,exitcode))
        end
    end
end
function M.check_unique_lang_to_ft()
    local tree_langs=vim.tbl_map(function (x)
        return vim.fn.fnamemodify(x,':t:r')
    end,vim.api.nvim_get_runtime_file('parser/*',true))
    local done=vim.deepcopy(require'ultimate-autopair.utils'.tslang2lang)
    local single=require'ultimate-autopair.utils'._tslang2lang_single
    for _,tree_lang in ipairs(tree_langs) do
        if done[tree_lang]=='' then goto continue end
        vim.treesitter.language.add(tree_lang)
        local filetypes=vim.treesitter.language.get_filetypes(tree_lang)
        local ft=done[tree_lang]
        if done[tree_lang] then
            if not vim.list_contains(filetypes,ft) and not single[tree_lang] then
                warn(('filetype `%s` in `utils.tslang2lang["%s"]` may be incorrect'):format(ft,tree_lang))
            end
        elseif #filetypes>1 then
            warn('Found multiple languages for '..tree_lang..': '..vim.inspect(filetypes))
        end
        done[tree_lang]=''
        ::continue::
    end
end
function M.check_cache(lua_path)
    for _,file in ipairs(vim.fn.readdir(lua_path..'/filter')) do
        for _,v in ipairs(require('ultimate-autopair.filter.'..file:sub(1,-5)).clear_cache) do
            if v~='textchange' and v~='treechange' and v:sub(1,4)~='opt:' then
                warn(('Invalid cache clear option `%s` in filter `%s`'):format(v,file:sub(1,-5)))
            end
            if v:sub(1,4)=='opt:' then
                if vim.api.nvim_get_option_info2(v:sub(5),{}).scope=='win' then
                warn(('Cache clear option `%s` is scope windows in filter `%s` which is not supported'):format(v,file:sub(1,-5)))
                end
            end
        end
    end
end
function M.start_dev(plugin_path,lua_path)
    start('Development checks')
    M.check_not_allowed_string(lua_path)
    M.check_unique_lang_to_ft()
    M.check_cache(lua_path)
    start('Tests')
    M.run_tests(plugin_path)
end
return M
