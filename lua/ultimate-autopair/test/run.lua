---@diagnostic disable-next-line: undefined-field
if _G.UA_IN_TEST then
    ---@diagnostic disable-next-line: duplicate-set-field
    function vim.lg(...)
        local d=debug.getinfo(2)
        return vim.fn.writefile(vim.fn.split(
            ':'..d.short_src..':'..d.currentline..':\n'..
            vim.inspect(#{...}==1 and ... or {...}),'\n'
        ),'/tmp/nlog','a')
    end
end
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
    debug=5,
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
            ---@diagnostic disable-next-line: undefined-field
            if category:sub(1,3)=='DEV' and not _G.UA_DEV then
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
        local err,mes=pcall(M.run_tests,conf,tests,has_not_ok)
        if not err then
            M.fn.error('DEBUG test runner error: '..mes)
            return
        end
    end
    for _,category in pairs(categorys) do
        ---@diagnostic disable-next-line: undefined-field
        if (not has_not_ok[category]) and category:sub(1,4)~='SKIP' and (_G.UA_DEV or category:sub(1,3)~='DEV') then
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
            if _G.UA_DEV then
                M.fn.info(('INFO test(%s) %s skiped'):format(category,testrepr))
            end
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
            info=stat --[[@as string]]
            stat=M.stat.err
        end
        ---@diagnostic disable-next-line: undefined-field
        if stat~=M.stat.ok and (_G.UA_DEV or stat~=M.stat.skip) then has_not_ok[category]=true end
        local testrepr=vim.inspect(testopt,{newline='',indent=''})
        if stat==M.stat.err then
            M.fn.error(('test(%s) %s errord: %s'):format(category,testrepr,info))
        elseif stat==M.stat.faild then
            M.fn.error(('test(%s) %s failed, actuall result: %s'):format(category,testrepr,vim.inspect(info)))
        elseif stat==M.stat.ok then
            ---@diagnostic disable-next-line: undefined-field
            if _G.UA_DEV=='ok' or category:sub(1,2)=='OK' then M.fn.ok(('test(%s) %s passed'):format(category,testrepr)) end
        elseif stat==M.stat.skip then
            ---@diagnostic disable-next-line: undefined-field
            if _G.UA_DEV then M.fn.info(('INFO test(%s) %s skiped'):format(category,testrepr)) end
        elseif stat==M.stat.debug then
            if _G.UA_DEV then M.fn.info(('DEBUG test(%s) %s, info: %s'):format(category,testrepr,info or '')) end
        else
            M.fn.warning('DEBUG: something went wrong')
        end
    end
end
function M.run_test(testopt)
    local map={
        ['']=ua_utils.keycode'<bs>',
        ['\r']=ua_utils.keycode'<cr>',
        ['']=ua_utils.keycode'<A-e>',
        ['']=ua_utils.keycode'<A-E>',
        ['']=ua_utils.keycode'<A-)>',
        ['']=ua_utils.keycode'<del>',
        ['']=ua_utils.keycode'<A-tab>',
    }
    local unparsed_starting_line,key,unparsed_resulting_line,opt=unpack(testopt)
    opt=opt or {}
    if opt.skip then return M.stat.skip end
    if opt.interactive then return M.stat.skip end
    local lines,linenr,col,line=M.parse_unparsed_line(unparsed_starting_line)
    if M.switch_ua_utils_fn(ua_utils,opt,lines,linenr,line,col) then return M.stat.skip end
    if #key~=1 then
        M.fn.warning('DEBUG: is not interactive and size of key is not 1')
    end
    local action=ua_core.run(map[key] or key)
    local deparsed_result_line=M.run_action(action,lines,linenr,col,opt)
    if deparsed_result_line~=unparsed_resulting_line then
        return M.stat.faild,deparsed_result_line
    end
    return M.stat.ok
end
function M.switch_ua_utils_fn(ua_utils_,opt,lines,linenr,line,col)
    ua_utils_._getlines=function () return lines end
    ua_utils_.getline=function () return line end
    ua_utils_._getlinecount=function() return #lines end
    ua_utils_.getmode=function () return opt.incmd and 'c' or 'i' end
    ua_utils_.incmd=function () return opt.incmd end
    ua_utils_.getcol=function () return col end
    ua_utils_.getlinenr=function () return linenr end
    if opt.ts then
        local s,parser=pcall(vim.treesitter.get_string_parser,vim.fn.join(lines,'\n'),opt.tsft or opt.ft or 'lua',{})
        if not s then return true end
        parser:parse()
        ua_utils_.gettsnode=function (o)
            local linenr_,col_=o.row+o._offset(o.row)-1,o.col+o._coloffset(o.col,o.row)-1
            local node=parser:named_node_for_range({linenr_,col_,linenr_,col_})
            return node
        end
    else
        ua_utils_.gettsnode=function (_) return nil end
    end
    ua_utils_.getsmartft=function () return opt.ft or '' end
    ua_utils_.getcmdtype=function () return opt.incmd end
end
function M.parse_unparsed_line(line)
    local lines=vim.split(line,'\n')
    local linenr
    local col
    for k,v in pairs(lines) do
        col=v:find('|')
        if col then
            linenr=k
            break
        end
    end
    line=lines[linenr]
    lines[linenr]=line:sub(0,col-1)..line:sub(col+1)
    return lines,linenr,col,line:sub(0,col-1)..line:sub(col+1)
end
function M.deparse_line(lines,linenr,col)
    local line=lines[linenr]
    lines[linenr]=line:sub(1,col-1)..'|'..line:sub(col)
    return vim.fn.join(lines,'\n')
end
function M.run_action(action,lines,row,col,opt)
    local i=1
    local function insert(str)
        lines[row]=lines[row]:sub(1,col-1)..str..lines[row]:sub(col)
        col=col+#str
    end
    local function delete(pre,pos)
        while pos and #lines[row]-col+1<pos and lines[row+1] do
            lines[row]=lines[row]..lines[row+1]
            table.remove(lines,row+1)
            pos=pos-1
        end
        while pre and pre>=col and lines[row-1] do
            row=row-1
            col=col+#lines[row]
            lines[row]=lines[row]..lines[row+1]
            table.remove(lines,row+1)
            pre=pre-1
        end
        lines[row]=lines[row]:sub(1,col-1-(pre or 0))..lines[row]:sub(col+(pos or 0))
        col=col-pre
    end
    while #action>i-1 do
        if action:sub(i,i)=='' then
            for k,v in pairs(opt.abbr or {}) do
                if vim.regex('\\<'..k):match_str(lines[row]:sub(col-#k-1,col)) then
                    delete(#k) insert(v) break
                end
            end
        elseif action:sub(i,i+4)==(opt.incmd and '\x80kl' or '\aU\x80kl') then
            col=col-1
            i=i+4
        elseif action:sub(i,i+2)=='\x80kb' then
            delete(1)
            i=i+2
        elseif action:sub(i,i+2)=='\x80kD' then
            delete(0,1)
            i=i+2
        elseif action:sub(i,i+2)=='\x80kd' then
            row=row+1
            i=i+2
        elseif action:sub(i,i+2)=='\x80ku' then
            row=row-1
            i=i+2
        elseif action:sub(i,i+2)=='\x80kh' then
            col=1
            i=i+2
        elseif action:sub(i,i+2)=='\x80@7' then
            col=#lines[row]+1
            i=i+2
        elseif action:sub(i,i+4)==(opt.incmd and '\x80kr' or '\aU\x80kr') then
            col=col+1
            i=i+4
        elseif action:sub(i,i)=='\r' then
            table.insert(lines,row+1,lines[row]:sub(col))
            lines[row]=lines[row]:sub(1,col-1)
            row=row+1
            col=1
        elseif action:sub(i,i)=='' then
        else
            insert(action:sub(i,i))
        end
        i=i+1
    end
    return M.deparse_line(lines,row,col)
end
return M
