local M={}

if vim.api.nvim_replace_termcodes('›',true,true,true)~='›' then
    ---@generic T:string|string?
    ---@param str T
    ---@return T
    function M.keycode(str) --TODO: once fixed in neovim, remove this
        if str and string.find(str,'[\128-\255]') then
            ---HACK: nvim_replace_termcodes converts all \x80 bytes, even if they are part of a utf8 char
            ---@cast str string
            local pos=vim.str_utf_pos(str)
            local out=''
            local sidx=1
            for k,v in ipairs(pos) do
                local c=str:sub(v,(pos[k+1] or 0)-1)
                if #c>1 and M.in_list({string.byte(c,2,-1)},128) then
                    out=out..vim.keycode(str:sub(sidx,v-1))..c
                    sidx=pos[k+1]
                end
            end
            return out..vim.keycode(sidx and str:sub(sidx) or '')
        end
        return str and vim.keycode(str)
    end
else
    ---@generic T:string|string?
    ---@param str T
    ---@return T
    function M.keycode(str)
        return str and vim.keycode(str)
    end
end

---@generic T
---@param list (T|any)[]
---@param value T
---@return boolean
function M.in_list(list,value)
    for _,v in ipairs(list) do
        if v==value then return true end
    end
    return false
end

---@param con ua.context
---@param range Range4
---@param nchars number
---@return string
function M.chars_before_range(con,range,nchars)
    ---TODO: check
    return M.utf8sub(M.line_before_range(con,range),-nchars)
end
---@param con ua.context
---@param range Range4
---@param nchars number
---@return string
function M.chars_after_range(con,range,nchars)
    ---TODO: check
    return M.utf8sub(M.line_after_range(con,range),1,nchars)
end
---@param con ua.context
---@param range Range4
---@return string
function M.line_before_range(con,range)
    ---TODO: check
    return select(2,con.iter_lines(range[1]+1,range[1]+1)()):sub(1,range[2])
end
---@param con ua.context
---@param range Range4
---@return string
function M.line_after_range(con,range)
    ---TODO: check
    return select(2,con.iter_lines(range[3]+1,range[3]+1)()):sub(range[4]+1)
end
---@param ranges Range4[]
---@param range Range4
function M.insert_range(ranges,range)
    if range[1]==range[3] and range[2]==range[4] then
        return
    end

    if #ranges==0 then
        table.insert(ranges,range)
        return
    end

    local idx=1
    local finish=#ranges
    local count=#ranges
    while idx~=finish do
        count=count-1
        assert(count>=0)

        local mid=math.floor((idx+finish)/2)
        if ranges[mid][3]<range[1] or (ranges[mid][3]==range[1] and ranges[mid][4]<range[2]) then
            idx=mid+1
        else
            finish=mid
        end
    end
    if ranges[idx][3]<range[1] or (ranges[idx][3]==range[1] and ranges[idx][4]<range[2]) then
        table.insert(ranges,range)
        return
    end
    if ranges[idx] and
        (ranges[idx][1]<range[1] or (ranges[idx][1]==range[1] and ranges[idx][2]<=range[2])) then
        if ranges[idx][3]>range[3] or (ranges[idx][3]==range[3] and ranges[idx][4]>=range[4]) then
            -- (.{.}.)
            return
        end
        -- (.{.).}

        range[1]=ranges[idx][1]
        range[2]=ranges[idx][2]
        table.remove(ranges,idx)
    end
    while ranges[idx] and M.range_in_range(range,ranges[idx],'both') do
        -- {.(.).}

        table.remove(ranges,idx)
    end
    if ranges[idx] and
        (ranges[idx][1]<range[3] or (ranges[idx][1]==range[3] and ranges[idx][4]<=range[4])) then
        -- {.(.}.)

        range[3]=ranges[idx][3]
        range[4]=ranges[idx][4]
        table.remove(ranges,idx)
    end
    table.insert(ranges,range)
end

---@param str string
---@param u_start number
---@param u_finish number?
---@return string
function M.utf8sub(str,u_start,u_finish)
    local b_start,b_finish
    local rev
    if u_start<0 then
        rev=vim.fn.reverse(str --[[@as nil[] ]]) --[[@as string]]
        b_start=#str-vim.str_byteindex(rev,'utf-32',(-u_start)-1)
        if b_start<=0 then
            b_start=1
        else
            b_start=vim.str_utf_start(rev,b_start)+b_start
        end
    else
        b_start=vim.str_byteindex(str,'utf-32',u_start-1)+1
    end
    if u_finish==nil then
        b_finish=-1
    elseif u_finish<0 then
        rev=rev or vim.fn.reverse(str --[[@as nil[] ]]) --[[@as string]]
        b_finish=#str-vim.str_byteindex(rev,'utf-32',(-u_finish)-1)
    else
        b_finish=vim.str_byteindex(str,'utf-32',u_finish-1)+1
        if b_finish>#str then
            b_finish=#str
        else
            b_finish=vim.str_utf_end(str,b_finish)+b_finish
        end
    end
    return str:sub(b_start,b_finish)
end

---@param range Range4
---@param contains_range Range4
---@param inclusive 'both'|'right'|'left'|false?
---@return boolean
function M.range_in_range(range,contains_range,inclusive)
    --If crange is zero width then and only then inclusive influence the result
    --So [f(oo)] is always true and [foo()] is true depending on if inclusive is set
    local crange=contains_range
    if crange[1]==crange[3] and crange[2]==crange[4]
        and crange[3]==range[3] and crange[4]==range[4] then
        return inclusive=='right' or inclusive=='both'
    elseif crange[1]==crange[3] and crange[2]==crange[4]
        and crange[1]==range[1] and crange[2]==range[2] then
        return inclusive=='left' or inclusive=='both'
    end
    return (range[1]<crange[1] or (range[1]==crange[1] and range[2]<=crange[2])) and
        (range[3]>crange[3] or (range[3]==crange[3] and range[4]>=crange[4]))
end

--TODO
function M.treesitter_enabled()
    return true
end
---@param con ua.context
---@return vim.treesitter.LanguageTree?
function M.get_parser(con)
    ---TODO: treesitter global switch
    if con._parser~=nil then
        return con._parser or nil
    end
    if con.bufnr==nil then
        local _,line=con.iter_lines(1,-1)()
        local isok,parser=pcall(vim.treesitter.get_string_parser,line..'\n','vim')
        con._parser=(isok and parser) or false
        if not isok or not parser then return end
        con._parser:parse(true)
        return con._parser or nil
    end
    assert(type(con.bufnr)=='number')
    local isok,parser=pcall(vim.treesitter.get_parser,con.bufnr)
    con._parser=(isok and parser) or false
    if not isok or not parser then
        return
    end

    if con.iconf.treesitter_async then
        vim.schedule(function ()
            parser:parse(true,function () end)
        end)
    else
        parser:parse(true)
    end
    return parser
end

M.tslang2lang={
    ---Last updated: 2025-09-10
    ---NOTE:
    --- When the following comments talks about corresponding to filetypes, they mean the return value of `vim.treesitter.language.get_filetype(lang)`
    --- When the following comments talks about filetypes which vim detects, they mean the filetypes which are defined inside `filetype.lua` (and other files used by `filetype.lua` (like `filetype/detect.lua`))

    -----Category 1 (these are languages correspond to multiple filetypes which vim detects (so we chose the most common one))
    ini='dosini',
    javascript='javascript',
    make='make',
    markdown='markdown',
    muttrc='muttrc',
    scala='scala',
    sql='sql',
    starlark='starlark',
    systemverilog='verilog',
    tcl='tcl',
    terraform='terraform',
    xml='xml',
    ---Category 2 (these languages are corresponding to only one filetype which vim detects)
    angular='htmlangular',
    bash='sh',
    bibtex='bib',
    c_sharp='cs',
    commonlisp='lisp',
    cooklang='cook',
    devicetree='dts',
    diff='diff',
    eex='eelixir',
    elixir='elixir',
    embedded_template='eruby',
    erlang='erlang',
    faust='faust',
    gdshader='gdshader',
    git_config='gitconfig',
    git_rebase='gitrebase',
    glimmer='handlebars',
    glimmer_javascript='javascript.glimmer',
    glimmer_typescript='typescript.glimmer',
    godot_resource='gdresource',
    haskell='haskell',
    haskell_persistent='haskellpersistent',
    html='html',
    idris='idris2',
    janet_simple='janet',
    latex='tex',
    linkerscript='ld',
    perl='perl',
    poe_filter='poefilter',
    powershell='ps1',
    properties='jproperties',
    python='python',
    qmljs='qml',
    rust='rust',
    slang='slang',
    ssh_config='sshconfig',
    surface='surface',
    t32='trace32',
    textproto='pbtxt',
    tlaplus='tla',
    tsx='typescriptreact',
    typescript='typescript',
    typst='typst',
    udev='udevrules',
    uxntal='tal',
    v='v',
    vento='vento',
    vhs='vhs',
    vimdoc='help',
    xresources='xdefaults',
    ---Category 3 (these languages don't correspond to any filetypes which vim detects)
    facility='fsd',
    m68k='m68k',
    runescript='runescript',
    ---Category 4 (same as category 3, but they should point to filetypes which vim detects)
    ---Unlike the above ones, these need not be be corresponding to multiple filetypes
    markdown_inline='markdown',
    [' markdown_inline']='',
    ocaml_interface='ocaml',
    [' ocaml_interface']='',
}
---@param con ua.context
---@param range Range4
---@return vim.treesitter.LanguageTree?,boolean?
function M.get_langtree(con,range)
    if con.__cache_get_lang and con.__cache_get_lang[range]~=nil then
        return con.__cache_get_lang[range][1],con.__cache_get_lang[range][2]
    end

    local parser=M.get_parser(con)
    if not parser then return end

    ---@param ltree vim.treesitter.LanguageTree
    local function lang_for_range(ltree)
        for _,child in pairs(ltree:children()) do
            for _,tree in pairs(child:trees()) do
                for _,trange in ipairs(tree:included_ranges(false)) do
                    if M.range_in_range(trange,range,'both') then
                        return lang_for_range(child),true
                    end
                end
            end
        end
        return ltree
    end

    local ltree,ischild=lang_for_range(parser)

    ---@diagnostic disable-next-line: inject-field
    con.__cache_get_lang={[range]={ltree,ischild}}

    return ltree,ischild
end
---@param con ua.context
---@param range Range4
---@return Range4?
---@return vim.treesitter.LanguageTree?
function M.get_tstree_range(con,range)
    local parser=M.get_parser(con)
    if not parser then return end

    ---@param ltree vim.treesitter.LanguageTree
    local function tree_for_range(ltree,trange)
        for _,child in pairs(ltree:children()) do
            for _,tree in pairs(child:trees()) do
                for _,trange_ in ipairs(tree:included_ranges(false)) do
                    if M.range_in_range(trange_,range,'both') then
                        return tree_for_range(child,trange_)
                    end
                end
            end
        end
        return trange,ltree
    end

    local trange,ltree=tree_for_range(parser)

    return trange,ltree
end
---@param tslang string
---@return string
function M.tslang_to_ft(tslang)
    return M.tslang2lang[tslang] or vim.treesitter.language.get_filetypes(tslang)[1] or tslang
end
---@param con ua.context
---@param range Range4
---@return string
function M.get_filetype(con,range)
    local ltree,ischild=M.get_langtree(con,range)

    if not ischild then return con.root_filetype end

    local tslang=assert(ltree):lang()
    local ret=M.tslang_to_ft(tslang)
    return ret
end
---@param con ua.context
---@param ft string
---@param opt string
---@return any
function M.ft_get_opt(con,ft,opt)
    local tbl_ft_getopt=con.iconf.use_filetype_getopt
    assert(type(tbl_ft_getopt)=='table')
    local ft_getopt=tbl_ft_getopt[ft]==nil and tbl_ft_getopt[true] or tbl_ft_getopt[ft] or false
    if ft_getopt==false then
        return vim.filetype.get_option(ft,opt)
    elseif ft_getopt==true then
        return vim.treesitter.get_option(ft,opt)
    end
    return assert(ft_getopt)(ft,opt)
end

---@param context {o:table}
---@param f function
---@return any
function M.with(context,f)
    local save={}
    local errmsg
    for k,v in pairs(context.o) do
        save[k]=vim.bo[k]
        vim.bo[k]=v
    end
    local _,ret=xpcall(f,function (msg) errmsg=debug.traceback(msg,2) end)
    for k,v in pairs(save) do
        vim.bo[k]=v
    end
    if errmsg then
        error(errmsg,0)
    end
    return ret
end

---@param iconf ua.iconfig
---@return ua.context
function M.create_context(iconf)
    if vim.fn.mode()=='c' then
        local line=vim.fn.getcmdline()
        local col=vim.fn.getcmdpos()
        ---@type ua.context
        return {
            cursor_range={0,col-1,0,col-1},
            iconf=iconf,
            root_filetype='vim',
            iter_lines=function (s,e)
                assert((s==1 or s==-1) and (e==1 or e==-1))
                return coroutine.wrap(function ()
                    coroutine.yield(1,line)
                end)
            end
        }
    end
    local bufnr=vim.api.nvim_get_current_buf()
    local row=vim.fn.line('.')
    local col=vim.fn.col('.')
    ---@type ua.context
    return {
        --TODO: in normal mode, the cursor is a block, not a beam
        cursor_range={row-1,col-1,row-1,col-1},
        iconf=iconf,
        bufnr=bufnr,
        root_filetype=vim.o.filetype,
        iter_lines=function (s,e)
            return coroutine.wrap(function ()
                if s<0 then
                    s=s+1+vim.api.nvim_buf_line_count(bufnr)
                end
                if e<0 then
                    e=e+1+vim.api.nvim_buf_line_count(bufnr)
                end
                for rows=s,e,(s<e and 1 or -1) do
                    coroutine.yield(rows,vim.api.nvim_buf_get_lines(bufnr,rows-1,rows,false)[1])
                end
            end)
        end
    }
end
---@param con ua.context
---@return ua.context
function M.context_to_singleline(con)
    --TODO: instead of returning a single line iter, return an iter, where everything besides the current line is ''(empty string)
    -- Why?: If the user creates a filter which takes info from the line above current, then it would error, or just not iter (though the erroring also happens if current line is first, so what would the best sulution be?)
    local row=con.cursor_range[1]+1
    return setmetatable({
        iter_lines=function ()
            return con.iter_lines(row,row)
        end},
        {__index=con})
end

return M
