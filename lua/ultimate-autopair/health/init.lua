local M={}

---@class ua.health.handler
M.default_handler={
  ok=function (msg) vim.notify('Ok: '..msg,vim.log.levels.DEBUG) end,
  info=function (msg) vim.notify('Info: '..msg,vim.log.levels.INFO) end,
  warn=function (msg) vim.notify('Warn: '..msg,vim.log.levels.WARN) end,
  error=function (msg) vim.notify('Error: '..msg,vim.log.levels.ERROR) end,
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

function M.check()
  local ok,val=pcall(vim.api.nvim_get_var,'ua')
  if not ok then val=_G.UA end
  M.start(val=='t' and 'test' or val --[[@as unknown]],M.health_handler)
end

---@param handler ua.health.handler
---@param lua_path string
---@param plugin_path string
local function check_not_allowed_string_and_typos(handler,lua_path,plugin_path)
  local blacklist={'v\zim.lg','p\zrint','v\zim.dev','v\zim.tbl_contains','v\zim.list_contains'}
  vim.fs.find(function(name,dir)
    local path=vim.fs.joinpath(dir,name)
    local row=0
    for line in io.lines(path) do
      row=row+1
      for _,word in ipairs(blacklist) do
        if line:find(word,nil,true) then
          handler.warn(('Found (blacklisted word) `%s` at:\n%s:%d:%s')
          :format(word,path,row,line))
        end
      end
    end
  end,{path=lua_path,type='file'})

  if vim.fn.executable('typos')==0 then
    handler.warn('`typos`(https://github.com/crate-ci/typos) not found, skipping checks which require it')
    return
  end

  local sym=vim.system({'typos'},{cwd=plugin_path}):wait(5000)
  if sym.stdout~='' then
    handler.warn('Found some typos:\n'..sym.stdout)
  elseif sym.code==124 then
    handler.warn('Timeout of shell job `typos`')
  elseif sym.code~=0 then
    handler.warn(('Shell job `typos` exited with code %d'):format(sym.code))
  end
end

---@param handler ua.health.handler
local function check_unique_lang_to_ft(handler)
  if not pcall(require,'nvim-treesitter') then
    handler.warn("nvim-treesitter not found, can't run nvim-treesitter related checks")
    return
  end

  local tree_langs=vim.tbl_map(function (x)
    return vim.fn.fnamemodify(x,':t:r')
  end,vim.api.nvim_get_runtime_file('parser/*',true))
  local done=vim.deepcopy(require'ultimate-autopair.util.treesitter'.tslang2lang)
  for _,tree_lang in ipairs(tree_langs) do
    if done[tree_lang]=='' then goto continue end
    vim.treesitter.language.add(tree_lang)
    local filetypes=vim.treesitter.language.get_filetypes(tree_lang)
    local ft=done[tree_lang]

    if done[tree_lang] then
      if not require'ultimate-autopair.util'.in_list(filetypes,ft) and not done[' '..tree_lang] then
        handler.warn(('filetype `%s` in `tslang2lang["%s"]` may be incorrect'):format(ft,tree_lang))
      end
    elseif #filetypes>1 then
      handler.warn('Found multiple languages for '..tree_lang..': '..vim.inspect(filetypes))
    -- elseif not require'ultimate-autopair.util'.in_list(vim.fn.getcompletion('','filetype'),filetypes[1]) then
    --   handler.warn(filetypes[1])
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

---@param handler ua.health.handler
---@param plugin_path string
---@param dev boolean
local function reload_and_run_tests(handler,plugin_path,dev)
  package.loaded['ultimate-autopair.test']=nil
  local test=require'ultimate-autopair.test'
  test.run_tests(plugin_path,handler,dev)
end

---@param handler ua.health.handler
---@return string?
local function get_plugin_lua_path(handler)
  local lua_path=vim.api.nvim_get_runtime_file('lua/ultimate-autopair',false)[1]
  if not lua_path then
    handler.error('Could not find ultimate-autopair plugin path')
    return
  end
  return lua_path
end

---@param dev boolean|'test'?
---@param handler ua.health.handler?
function M.start(dev,handler)
  handler=handler or M.default_handler

  if dev=='test' then
    local lua_path=get_plugin_lua_path(handler)
    if lua_path then
      local plugin_path=vim.fs.dirname(vim.fs.dirname(lua_path))
      reload_and_run_tests(handler,plugin_path,false)
    end
    return
  end

  if vim.fn.has('nvim-0.10.1')~=1 then
    handler.error(('Your neovim version is not supported (please use 0.10.1 or newer)'))
    return
  elseif vim.fn.has('nvim-0.11.1')~=1 then
    handler.warn('Use 0.11.1 or newer for better performance')
  end

  -- -- TODO:
  -- local conf=require'ultimate-autopair'._conf
  -- if not conf then
  --   handler.warn("No config detected, can't validate config")
  -- else
  --   validate_user_config(handler,conf)
  -- end

  if not dev then
    -- -- TODO:
    -- handler.info('... to run more checks, read ...')
    return
  end
  handler.start('Running development chesk')

  local lua_path=get_plugin_lua_path(handler)
  if not lua_path then
    return
  end
  local plugin_path=vim.fs.dirname(vim.fs.dirname(lua_path))

  check_not_allowed_string_and_typos(handler,lua_path,plugin_path)
  check_unique_lang_to_ft(handler)
  -- -- TODO:
  -- validate_default_configs(handler)
  reload_and_run_tests(handler,plugin_path,true)
end

return M
