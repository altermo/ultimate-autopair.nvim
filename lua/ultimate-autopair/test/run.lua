local M={}
local list_of_tests=require'ultimate-autopair.test.test'
local ua=require'ultimate-autopair'
local ua_core=require'ultimate-autopair.core'
local ua_utils=require'ultimate-autopair.utils'
M.stat={
    ok=1,
    err=2,
    faild=3,
    skip=4,
}
function M.generate_output_funcs(outfile)
    return {
        ok=function (msg)
            vim.fn.writefile({'OK´'..msg},outfile,'a')
        end,
        error=function (msg)
            vim.fn.writefile({'ERR´'..msg},outfile,'a')
        end,
        warning=function (msg)
            vim.fn.writefile({'WARN´'..msg},outfile,'a')
        end,
        info=function (msg)
            vim.fn.writefile({'INFO´'..msg},outfile,'a')
        end,
    }
end
function M.sort_test_by_conf(list_tests)
    local ret={skip={}}
    for category,tests in pairs(list_tests) do
        for _,testopt in pairs(tests) do
            if category:sub(1,4)=='SKIP' then
                goto continue
            end
            testopt._category=category
            if testopt[4] and testopt[4].skip then
                table.insert(ret.skip,testopt)
                goto continue
            end
            local testconf=testopt[4] and testopt[4].c or {}
            for config,_ in pairs(ret) do
                if vim.deep_equal(config,testconf) then
                    table.insert(ret[config],testopt)
                    goto continue
                end
            end
            ret[testconf]={testopt}
            ::continue::
        end
    end
    return ret
end
function M.run(outfile)
    M.fn=M.generate_output_funcs(outfile)
    local conf_tests=M.sort_test_by_conf(list_of_tests)
    local categorys=vim.tbl_keys(list_of_tests)
    local has_not_ok={}
    for conf,tests in pairs(conf_tests) do
        M.run_tests(conf,tests,has_not_ok)
    end
    for _,category in pairs(categorys) do
        if not has_not_ok[category] and not category:sub(1,4)=='SKIP' then
            M.fn.ok('all test in category `'..category..'` have passed')
        end
    end
    vim.fn.writefile({},outfile,'a')
end
function M.run_tests(conf,tests,has_not_ok)
    if conf=='skip' then
        for _,testopt in ipairs(tests) do
            local category=testopt._category
            testopt._category=nil
            local testrepr=vim.inspect(testopt,{newline='',indent=''})
            M.fn.info(('INFO test(%s) %s skiped'):format(category,testrepr))
        end
        return
    else
        local err,info=pcall(ua.setup,conf)
        if not err then
            M.fn.error(('DEBUG: the config (or a PREVIOUS config) caused an error, conf: %s, error: %s'):format(vim.inspect(conf),info))
        end
    end
    for _,testopt in ipairs(tests) do
        local category=testopt._category
        testopt._category=nil
        local err,stat,info=pcall(M.run_test,testopt)
        if not err then
            info=stat
            stat=M.stat.err
        end
        if stat~=M.stat.ok then has_not_ok[category]=true end
        local testrepr=vim.inspect(testopt,{newline='',indent=''})
        if stat==M.stat.err then
            M.fn.error(('test(%s) %s errord: %s'):format(category,testrepr,info))
        elseif stat==M.stat.faild then
            M.fn.error(('test(%s) %s failed, actuall result: %s'):format(category,testrepr,vim.inspect(info)))
        elseif stat==M.stat.ok then --TODO: optio
            M.fn.ok(('test(%s) %s passed'):format(category,testrepr))
        elseif stat==M.stat.skip then
            M.fn.info(('INFO test(%s) %s skiped'):format(category,testrepr))
        else
            M.fn.warning('DEBUG: something went wrong')
        end
    end
end
function M.run_test(testopt)
    local map={
        ['']='<bs>',
        ['']='<C-e>',
        ['']='<C-S-e>',
        ['']='<A-)>',
    }
    local unparsed_starting_line,key,unparsed_resulting_line,opt=unpack(testopt)
    opt=opt or {}
    if opt.interactive then return M.stat.skip end
    if opt.ts then return M.stat.skip end
    if opt.skip then return M.stat.skip end
    local col,line=M.parse_unparsed_line(unparsed_starting_line)
    M.switch_ua_utils_fn(ua_utils,opt,line,col)
    if #key~=1 then
        M.fn.warning('DEBUG: size of key is not 1 and is not interactive')
    end
    local action=ua_core.run(map[key] or key)
    local deparsed_result_line=M.run_action(action,line,col,opt)
    if deparsed_result_line~=unparsed_resulting_line then
        return M.stat.faild,deparsed_result_line
    end
    return M.stat.ok
end
function M.switch_ua_utils_fn(ua_utils_,opt,line,col)
    ua_utils_.getline=function () return line end
    ua_utils_.getlines=function () return {line} end
    ua_utils_.incmd=function () return false end
    ua_utils_.getcol=function () return col end
    ua_utils_.getlinenr=function () return 1 end
    ua_utils_.gettsnode=function () end
    ua_utils_.getsmartft=function () return opt.ft or '' end
    ua_utils_.getcmdtype=function () return ':' end
end
function M.parse_unparsed_line(line)
    local col=line:find('|')
    return col,line:sub(0,col-1)..line:sub(col+1)
end
function M.deparse_line(line,col)
    return line:sub(1,col-1)..'|'..line:sub(col)
end
function M.run_action(action,line,col,opt)
    local i=1
    local function insert(str)
        line=line:sub(1,col-1)..str..line:sub(col)
        col=col+#str
    end
    local function delete(pre,pos)
        line=line:sub(1,col-1-(pre or 0))..line:sub(col+(pos or 0))
        col=col-pre
    end
    while #action>i-1 do
        if action:sub(i,i)=='' then
            for k,v in pairs(opt.abbr or {}) do
                if vim.regex('\\<'..k):match_str(line:sub(col-#k-1,col)) then
                    delete(#k) insert(v) break
                end
            end
        elseif action:sub(i,i+4)=='\aU\x80kl' then
            col=col-1
            i=i+4
        elseif action:sub(i,i+2)=='\x80kb' then
            delete(1)
            i=i+2
        elseif action:sub(i,i+2)=='\x80kD' then
            delete(0,1)
            i=i+2
        elseif action:sub(i,i+4)=='\aU\x80kr' then
            col=col+1
            i=i+4
        else
            insert(action:sub(i,i))
        end
        i=i+1
    end
    return M.deparse_line(line,col)
end
return M