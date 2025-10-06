local utils=require'ultimate-autopair.utils'
local M={}
---@class ua.health.handler
M.default_handler={
    ok=function (msg) vim.notify('Ok: '..msg) end,
    info=function (msg) vim.notify('Info: '..msg) end,
    warn=function (msg) vim.notify('Warn: '..msg) end,
    error=function (msg) vim.notify('Error: '..msg) end,
    start=function (_) end,
}
---@type ua.health.handler
M.health_handler={
    ok=vim.health.ok or vim.health.report_ok,
    info=vim.health.info or vim.health.report_info,
    warn=vim.health.warn or vim.health.report_warn,
    error=vim.health.error or vim.health.report_error,
    start=vim.health.start or vim.health.report_start,
}

---@param handler ua.health.handler
---@param is_default boolean?
local function validate_config(handler,is_default)
    local conf
    if is_default then
        handler.start('Default configuration validation')
        ---TODO: if multiple default configs, validate all of them
        conf=require'ultimate-autopair.def-merge'.conf.default
        assert(conf)
    else
        handler.start('Configuration validation')
        conf=require'ultimate-autopair'._conf
        conf={} --TODO
        if not conf then
            handler.warn("No config detected, can't validate config")
            return
        end
    end
    local err_out={}
    local is_not_err,err=pcall(require'ultimate-autopair.conf'._generate,conf,{
        validate=4,
        err_format=err_out,
    })
    if not is_not_err then
        if type(err)=='string' then
            handler.error('Error while validating config: \n'..err)
        else
            ---@diagnostic disable-next-line: undefined-field
            handler.error('Config is invalid: >\n'..err.msg)
            handler.info'' -- is for ending code block
        end
        return
    end
    if vim.tbl_isempty(err_out) then
        handler.ok('Config is valid')
        return
    end
    handler.warn('Config is VALID, but may be problematic: >\n'..table.concat(vim.tbl_map(function (x) return x.msg end,err_out),'\n\n'))
    handler.info'' -- is for ending code block
end

---@param handler ua.health.handler
local function validate_externals(handler)
    handler.start('External (optional) plugins')
    if not pcall(require,'nvim-treesitter') then
        handler.warn('nvim-treesitter not found')
        handler.info('NOTE: nvim-treesitter is not required if parsers are installed through other ways')
    else
        handler.ok('nvim-treesitter found')
    end
end

---@param handler ua.health.handler
---@param lua_path string
---@param plugin_path string
local function check_not_allowed_string_and_typos(handler,lua_path,plugin_path)
    local jobs={}
    local jobsdata={}
    if vim.fn.executable('grep')==1 then
        local blacklist={'v\zim.lg','p\zrint','v\zim.dev','v\zim.tbl_contains','v\zim.list_contains'}
        local search=table.concat(blacklist,'\\|')
        local flag=false
        local job=vim.fn.jobstart({'grep','-r',search,lua_path},{on_stdout=function (_,data,_)
            for _,v in ipairs(data) do
                if v~='' then
                    if not flag then
                        handler.info('The following strings are not allowed: `'..table.concat(blacklist,'`, `')..'`')
                        handler.info('INFO Replace any `v\zim.tbl_contains` and `v\zim.list_contains` with `utils.in_list`')
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
    ---TODO: check if treesitter language by default maps to filetype (using getcompletion('filetype') to get the filetypes)...
    ---TODO: also main/master treesitter uses different language<=>filetype, ... (maybe have a info section about it or solve the problem...)
    local tree_langs=vim.tbl_map(function (x)
        return vim.fn.fnamemodify(x,':t:r')
    end,vim.api.nvim_get_runtime_file('parser/*',true))
    local done=vim.deepcopy(require'ultimate-autopair.utils'.tslang2lang)
    for _,tree_lang in ipairs(tree_langs) do
        if done[tree_lang]=='' then goto continue end
        vim.treesitter.language.add(tree_lang)
        local filetypes=vim.treesitter.language.get_filetypes(tree_lang)
        local ft=done[tree_lang]

        if done[tree_lang] then
            if not utils.in_list(filetypes,ft) and not done[' '..tree_lang] then
                handler.warn(('filetype `%s` in `utils.tslang2lang["%s"]` may be incorrect'):format(ft,tree_lang))
            end
        elseif #filetypes>1 then
            handler.warn('Found multiple languages for '..tree_lang..': '..vim.inspect(filetypes))
        end
        done[tree_lang]=''
        ::continue::
    end
    for k,v in pairs(done) do
        if v~='' and k:sub(1,1)~=' ' then
            handler.warn('filetype '..k..' in utils.tslang2lang['..v..'] can be removed')
        end
    end
end

local function reload_and_run_tests(handler,plugin_path,dev)
    package.loaded['ultimate-autopair.test']=nil
    local test=require'ultimate-autopair.test'
    test.run_tests(plugin_path,handler,dev)
end

function M.check()
    M.start(false,M.health_handler)
end

---@param dev boolean?
---@param handler ua.health.handler
function M.start(dev,handler)
    handler=handler or M.default_handler
    if vim.fn.has('nvim-0.10.1')~=1 then
        handler.error(('Your neovim version is not supported (please use 0.10.1 or newer)'))
        return
    end
    if vim.fn.has('nvim-0.11.1')~=1 then
        handler.warn('Use 0.11.1 or newer for better performance')
    end

    validate_config(handler)
    validate_externals(handler)

    if not dev then return end
    handler.info('Development chesks are enabled')

    handler.start('Development checks')
    local lua_path=vim.api.nvim_get_runtime_file('lua/ultimate-autopair',false)[1]
    if not lua_path then
        handler.error('Could not find ultimate-autopair plugin path')
        return
    end
    local plugin_path=vim.fs.dirname(vim.fs.dirname(lua_path))
    check_not_allowed_string_and_typos(handler,lua_path,plugin_path)
    check_unique_lang_to_ft(handler)
    validate_config(handler,true)
    reload_and_run_tests(handler,plugin_path,dev)
end
return M
