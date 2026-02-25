local function list_of_test_fn(_)
  ---@diagnostic disable: duplicate-index
  ---@type ua.test[]
  local tests={
    [1]=false --[[@as unknown]],

    --## simple
    [_()]={'|','(','(|)'},
    [_()]={'|)','(','(|)'},
  }
  ---@diagnostic enable: duplicate-index
  return tests
end

---@class ua.test.pre
---@field [1] string
---@field [2] string
---@field [3] string
---@field [4] ua.config?
---@field I any?
---@field trim boolean?
---@field cmd string?
---@field ft string?

---@class ua.test: ua.test.pre
---@field def_info debuglib.DebugInfo
---@field id number

local M={}

do
  local test_to_def_info={}
  local n=0
  tests=list_of_test_fn(function()
    n=n+1
    test_to_def_info[n]=debug.getinfo(2)
    return n+1
  end)
  assert(table.remove(tests,1)==false,'Forgot to add `[_()]=`')

  for idx,test in ipairs(tests) do
    assert(type(test[1])=='string')
    assert(type(test[2])=='string')
    assert(type(test[3])=='string')
    assert(test[1]:find('|'))
    assert(not test[2]:find('|'))
    assert(test[3]:find('|'))
    assert(test[4]==nil or type(test[4])=='table')

    test.def_info=assert(test_to_def_info[idx])
    test.id=idx

    if test.I then
      M.tests={test}
      break
    end
  end
  ---@cast tests ua.test[]
  M.tests=tests
end

---@class ua.test.instance
---@field handler ua.health.handler
---@field _chan integer
local instance_meta={}
---@return any
function instance_meta:request(...)
  return vim.rpcrequest(self._chan,...)
end
---@param cmd string
---@return string
function instance_meta:exec(cmd)
  return self:request('nvim_exec2',cmd,{output=true}).output
end
---@param cmd string
---@return any
function instance_meta:exec_lua(cmd,...)
  return self:request('nvim_exec_lua',cmd,{...})
end
---@param cmd string
---@return boolean,any
function instance_meta:exec_lua_pcall(cmd,...)
  return pcall(self.exec_lua,self,cmd,...)
end
local function create_instance(handler)
  local chan=vim.fn.jobstart({vim.v.progpath,'--embed','--headless','--clean','-i','NONE','-u','NONE'},{rpc=true})
  vim.schedule(function ()
    pcall(vim.fn.jobstop, chan)
  end)
  return setmetatable({
    handler=handler,
    _chan=chan,
  },{__index=instance_meta})
end

---@param test ua.test
---@return string
local function testdefpath(test)
  return ('%s:%d')
  :format(test.def_info.source,test.def_info.currentline)
end

---@param instance ua.test.instance
---@param str string
local function set_lines_and_pos(instance,str)
  local lines=vim.split(str,'\n')
  ---@type integer?,integer?
  local row,col
  for k,v in ipairs(lines) do
    col=v:find('|',1,true)
    if col then row=k break end
  end
  assert(row and col and lines[row])
  lines[row]=lines[row]:sub(0,col-1)..lines[row]:sub(col+1)
  instance:request('nvim_buf_set_lines',0,0,-1,true,lines)
  instance:request('nvim_win_set_cursor',0,{row,col-1})
end

---@param instance ua.test.instance
---@param input string
local function feed(instance,input)
  if instance:request('nvim_input',input)~=#input then return false end
  local errmsg=instance:request('nvim_get_vvar','errmsg')
  if errmsg~='' then instance:exec('let v:errmsg=""') end
  return errmsg
end
---@param instance ua.test.instance
---@param trim boolean?
local function get_lines_and_pos(instance,trim)
  local lines=instance:request('nvim_buf_get_lines',0,0,-1,true)
  local row,col=unpack(instance:request('nvim_win_get_cursor',0))
  lines[row]=lines[row]:sub(1,col)..('|')..lines[row]:sub(col+1)
  local line=table.concat(lines,'\n')
  if trim then
    line=vim.trim(line)
  end
  return line
end
---@param test ua.test
---@param actual string?
---@return string
local function create_backtrace(test,actual)
  local lines={
    '{Test-path}:',
    testdefpath(test),
    '{Initial}:',
    test[1],
    ('{Input}: `%s`'):format(test[2]),
    '{Expected-result}:',
    test[3],
  }
  if actual then
    table.insert(lines,'{Actual-result}:')
    table.insert(lines,actual)
  end
  test[1]=nil
  test[2]=nil
  test[3]=nil
  test.def_info=nil
  test.id=nil
  if next(test) then
    table.insert(lines,3,'{Test-opts}:')
    table.insert(lines,4,vim.inspect(test))
  end
  return table.concat(lines,'\n')
end


---@param instance ua.test.instance
---@param test ua.test
local function run_test(instance,test)
  instance:exec('stopinsert')
  instance:exec('bwipeout!')
  instance:exec_lua('vim.cmd.edit(...)',vim.fn.tempname())
  instance:exec('set all&')
  instance:exec('startinsert')

  if test.ft then
    instance:exec_lua('vim.cmd.setf(...)',test.ft)
  end
  if test.cmd then
    instance:exec(test.cmd)
  end

  set_lines_and_pos(instance,test[1])
  local errmsg=feed(instance,test[2])

  if errmsg==false then
    local msg=('test(%s) went wrong:\nThe input could not be processed\nPossible reason: An unmatched `<` may be in the input, replace all unmatched `<` with `<lt>`\n%s')
    :format(test.id,create_backtrace(test))
    instance.handler.error(msg)
  elseif errmsg~='' then
    local msg=('test(%s) errord:\n%s\n%s'):format(test.id,errmsg,create_backtrace(test))
    if msg:find'\0' then
      msg=vim.re.gsub(msg,'[\0]','\\0')
    end
    instance.handler.error(msg)
    -- When a test errors, it is slow, and one errord test typically means multiple errord tests
    -- So we don't stop test execution here so that the test execution doesn't take so long
    return 'error'
  elseif get_lines_and_pos(instance,test.trim)~=test[3] then
    local msg=('test(%s) failed:\n%s')
    :format(test.id,create_backtrace(test,get_lines_and_pos(instance,test.trim)))
    instance.handler.error(msg)
  end
end

---@param tests ua.test[]
local organize_tests_by_config=function (tests)
  local config_to_tests={}
  for _,test in ipairs(tests) do
    local conf=test[4] or {}

    for config in pairs(config_to_tests) do
      if vim.deep_equal(conf,config) then
        table.insert(config_to_tests[config],test)
        goto continue
      end
    end

    config_to_tests[conf]={test}
    ::continue::
  end
  return config_to_tests
end

---@param plugin_path string
---@param handler ua.health.handler
---@param dev boolean
function M.run_tests(plugin_path,handler,dev)
  handler=handler or require'ultimate-autopair.health'.default_handler

  if dev then
    for _,test in ipairs(M.tests) do
      if test.I then
        handler.error(('`I`(ignore all other) set for test %d at %s')
        :format(test.id,testdefpath(test)))
      end
    end
  end

  handler.start('Running tests')

  local instance=create_instance(handler)
  instance:exec_lua('vim.opt.runtimepath:append(...)',plugin_path)
  instance:exec_lua('_G._UA_IN_TEST=true',plugin_path)
  instance:exec_lua[[
  _G._UA_PRINT={}
  vim['p\zrint']=function (...)
    table.insert(_G._UA_PRINT,vim.inspect(select('#',...)<2 and ... or {...}))
  end]]

  for _,tests in pairs(organize_tests_by_config(M.tests)) do
    instance:exec_lua([[
    local index=...
    local ua_conf=require'ultimate-autopair.test'.tests[index][4]
    require'ultimate-autopair'.setup(ua_conf)
    ]],tests[1].id)

    for _,test in ipairs(tests) do
      if run_test(instance,test)=='error' then
        handler.warn('Unrecoverable error happened: Prematurely stopping test execution')
        goto break_
      end
    end
  end
  ::break_::
  if vim.fn.jobstop(instance._chan)==0 then
    handler.error('Could not stop test neovim instance execution: already stopped')
  end
end

return M
