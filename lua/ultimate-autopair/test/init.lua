local utils=require'ultimate-autopair.test.utils'
local  M={}
function M.check_not_allowed_string(path)
    if vim.fn.executable('grep')==0 then
        utils.warning('Some of the required executables are missing for dev testing')
        utils.info('INFO Please make sure that `grep` is installed')
        return
    end
    local blacklist={'vim.lg','print','vim.dev'}
    local search=table.concat(blacklist,'\\|')
    local job=vim.fn.jobstart({'grep','-r','--exclude-dir=test',search,path},{on_stdout=function (_,data,_)
        for _,v in ipairs(data) do
            if v=='' then return end
            utils.warning('Found something not allowed: '..v:sub(v:sub(2):find(' ') or 1))
        end
    end})
    debug.setmetatable(job,{name='grep',expected=1})
    local jobs={job}
    for k,exitcode in ipairs(vim.fn.jobwait(jobs,5000)) do
        local mt=getmetatable(jobs[k])
        if exitcode==-1 then
            utils.warning(('timeout `%s`'):format(mt.name))
        elseif exitcode~=(mt.expected or 0) then
            utils.warning(('job `%s` exited with code %s'):format(mt.name,exitcode))
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
            if not vim.tbl_contains(filetypes,ft) and not single[tree_lang] then
                utils.warning(('filetype `%s` in `utils.tslang2lang["%s"]` may be incorrect'):format(ft,tree_lang))
            end
        elseif #filetypes>1 then
            utils.warning('Found multiple languages for '..tree_lang..': '..vim.inspect(filetypes))
        end
        done[tree_lang]=''
        ::continue::
    end
end
function M.check_default_config()
    local confspec=require'ultimate-autopair.profile.pair.confspec'
    local s,err=pcall(confspec.validate,require'ultimate-autopair.default'.conf,'main')
    if not s then utils.error(err) end
    s,err=pcall(confspec.validate,confspec.generate_random('main'),'main')
    if not s then utils.error(err) end
end
function M.start()
    local lua_path=vim.api.nvim_get_runtime_file('lua/ultimate-autopair',false)[1]
    local plugin_path=vim.fn.fnamemodify(lua_path,':h:h')
    if _G.UA_DEV then
        M.check_not_allowed_string(lua_path)
        M.check_unique_lang_to_ft()
        M.check_default_config()
    end
    if vim.fn.has('nvim-0.9.0')==0 then
        utils.warning('You have an older version of neovim than recommended')
    end
    if not pcall(require,'nvim-treesitter') then
        utils.warning('nvim-treesitter not installed: is required for treesitter specific behavior')
        utils.info('NOTE: nvim-treesitter is not required if parsers are installed through another way')
    end
    if not pcall(require,'nvim-treesitter-endwise') then
        utils.info('nvim-treesitter-endwise not installed: endwise integration will not work')
    end
    if not pcall(require,'nvim-ts-autotag') then
        utils.info('nvim-ts-autotag not installed: autotag integration will not work')
    end
    require'ultimate-autopair.test.run'.run(plugin_path)
end
return M
