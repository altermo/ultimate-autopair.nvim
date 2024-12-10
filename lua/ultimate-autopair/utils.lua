local M={}
---- ;; key utils
---@generic T:string|string?
---@param str T
---@return T
function M.keycode(str)
    if str and (str --[[@as string]]):find('\x80') then
        ---HACK: nvim_replace_termcodes converts all \x80 bytes, even ones part of unicode char
        ---see: https://github.com/neovim/neovim/issues/17369
        return (vim.api.nvim_replace_termcodes(str,true,true,true):gsub('\128\254\88','\128'))
    end
    return str and vim.api.nvim_replace_termcodes(str,true,true,true)
end
M.key_bs=M.keycode'<bs>'
M.key_del=M.keycode'<del>'
M.key_left=M.keycode'<left>'
M.key_right=M.keycode'<right>'
M.key_end=M.keycode'<end>'
M.key_home=M.keycode'<home>'
M.key_up=M.keycode'<up>'
M.key_down=M.keycode'<down>'
M.key_noundo=M.keycode'<C-g>U'
M.key_i_ctrl_o=M.keycode'<C-\\><C-o>'
---@param key string
---@return string
function M.key_normalize(key)
    return vim.fn.keytrans(M.keycode(key))
end

---- ;; list utils
---@generic T
---@param list (T|any)[]
---@param item T
---@return boolean
function M.in_list(list,item)
    for _,i in ipairs(list) do
        if i==item then return true end
    end
    return false
end

---- ;; string utils
---@param str string
---@param start number
---@param finish number?
---@return string
function M.utf8sub(str,start,finish)
    local nstr
    if start==2 and finish==nil then
        nstr=str:sub(vim.str_utf_end(str,1)+2)
    end
    if start==1 and finish==-2 then
        nstr=str:sub(1,vim.str_utf_start(str,#str)-2)
    end
    if start==-1 and finish==nil then
        nstr=str:sub(vim.str_utf_start(str,#str)-1)
    end
    if start==1 and finish==1 then
        nstr=str:sub(1,vim.str_utf_end(str,1)+1)
    end
    if not nstr then
        error('TODO')
    end
    return nstr
end
---@param str string
---@param prefix string
---@return boolean
function M.startwith(str,prefix)
    return str:sub(1,#prefix)==prefix
end
---@param str string
---@param suffix string
---@return boolean
function M.endswith(str,suffix)
    if #suffix==0 then return true end
    return str:sub(-#suffix)==suffix
end
M.len=vim.api.nvim_strwidth

---- ;; language/filetype utils
M.tslang2lang={
    ---Last updated: 2024-07-25
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
    tcl='tcl',
    terraform='terraform',
    verilog='verilog',
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
    markdown_inline={'markdown'},
    ocaml_interface={'ocaml'},
}
M.opt_ftgetopt={[true]=true}
function M.ftgetopt(ft,opt)
    local o=M.opt_ftgetopt[opt]
    if o==nil then o=M.opt_ftgetopt[true] end
    assert(o~=nil)
    if o==true then
        return vim.filetype.get_option(ft,opt)
    elseif o==false then
        return vim.api.nvim_get_option_value(opt,{})
    else
        return o(ft,opt)
    end

end

---- ;; context utils
---@return ua.context.pos
function M.create_context()
    local source
    local line_pre,line_pos
    local col,row
    if vim.fn.mode()=='c' then
        row=1
        col=vim.fn.getcmdpos()
        local line=vim.fn.getcmdline()
        line_pre=line:sub(1,col-1)
        line_pos=line:sub(col)
        ---@type ua.source
        source={
            iter_lines=function (s,e)
                assert((s==1 or s==-1) and (e==1 or e==-1))
                return coroutine.wrap(function ()
                    coroutine.yield(1,line)
                end)
            end
        }
    else
        local line=vim.api.nvim_get_current_line()
        row=vim.fn.line('.')
        col=vim.fn.col('.')
        line_pre=line:sub(1,col-1)
        line_pos=line:sub(col)
        ---@type ua.source
        source={
            bufnr=vim.api.nvim_get_current_buf(),
            iter_lines=function (s,e)
                return coroutine.wrap(function ()
                    if s<0 then
                        s=s+1+vim.api.nvim_buf_line_count(source.bufnr)
                    end
                    if e<0 then
                        e=e+1+vim.api.nvim_buf_line_count(source.bufnr)
                    end
                    for rows=s,e,(s<e and 1 or -1) do
                        coroutine.yield(rows,vim.api.nvim_buf_get_lines(source.bufnr,rows-1,rows,false)[1])
                    end
                end)
            end
        }
    end
    ---@type ua.context.pos
    return {
        source=source,
        line_pre=line_pre,
        line_pos=line_pos,
        col=col,
        row=row,
    }
end
---@param con ua.context.pos
---@return table
function M.conset(con,opts)
    return setmetatable(opts,{__index=con})
end
---@param con ua.context.pos
---@return ua.context.pos
function M.make_con_singleline(con)
    return M.conset(con,{
        source=setmetatable({
            iter_lines=function ()
                return con.source.iter_lines(con.row,con.row)
            end
        },{
            __index=con.source
        }),
    })
end

--- ;; init
function M.init(conf)
    assert(conf.use_filetype_getopt)
    assert(conf.use_filetype_getopt[true]~=nil)
    M.ftgetopt=conf.use_filetype_getopt
end
return M
