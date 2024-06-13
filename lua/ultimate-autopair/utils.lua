---@alias ua._.str_buf string.buffer
local M={I={}}
M.I.len=vim.api.nvim_strwidth
---@generic T:string|string?
---@param str T
---@return T
function M.keycode(str)
    if str and #str~=M.I.len(str) then
        ---HACK: nvim_replace_termcodes converts all \x80 bytes, even if they are part of a utf8 char
        ---@cast str string
        local pos=vim.str_utf_pos(str)
        local out=''
        local sidx=1
        for k,v in ipairs(pos) do
            local c=str:sub(v,(pos[k+1] or 0)-1)
            if #c>1 and vim.list_contains({string.byte(c,2,-1)},128) then
                out=out..vim.api.nvim_replace_termcodes(str:sub(sidx,v-1),true,true,true)..c
                sidx=pos[k+1]
            end
        end
        return out..vim.api.nvim_replace_termcodes(sidx and str:sub(sidx) or '',true,true,true)
    end
    return str and vim.api.nvim_replace_termcodes(str,true,true,true)
end
M.I.key_bs=M.keycode'<bs>'
M.I.key_del=M.keycode'<del>'
M.I.key_left=M.keycode'<left>'
M.I.key_right=M.keycode'<right>'
M.I.key_end=M.keycode'<end>'
M.I.key_home=M.keycode'<home>'
M.I.key_up=M.keycode'<up>'
M.I.key_down=M.keycode'<down>'
M.I.key_noundo=M.keycode'<C-g>U'
M.I.key_i_ctrl_o=M.keycode'<C-\\><C-o>'
---@param minsize number
---@return ua._.str_buf
function M.new_str_buf(minsize)
    return require'string.buffer'.new(minsize)
end
---@param str string
---@return string
function M.key_normalize(str)
    return vim.fn.keytrans(M.keycode(str))
end
---@param len string|number|nil
---@param noundo boolean?
---@return string
function M.key_left(len,noundo)
    len=type(len)=='string' and M.I.len(len) or len or 1
    return ((noundo and M.I.key_noundo or '')..M.I.key_left):rep(len --[[@as number]])
end
---@param len string|number|nil
---@param noundo boolean?
---@return string
function M.key_right(len,noundo)
    len=type(len)=='string' and M.I.len(len) or len or 1
    return ((noundo and M.I.key_noundo or '')..M.I.key_right):rep(len --[[@as number]])
end
---@param pre? number
---@param pos? number
---@return string
function M.key_del(pre,pos)
    pre=type(pre)=='string' and M.I.len(pre) or pre or 1
    pos=type(pos)=='string' and M.I.len(pos) or pos or 0
    return M.I.key_bs:rep(pre)..M.I.key_del:rep(pos)
end
---@param col number
---@param row number?
---@param mode string
---@return string
function M.key_pos_nodot(col,row,mode)
    if mode=='i' or mode=='R' then
        --M.I.key_i_ctrl_o is important because otherwise things break internally (like undo)
        return M.I.key_i_ctrl_o..M.keycode(('<cmd>call cursor(%s,%s)\r'):format(row or '"."',col))
    elseif mode=='c' then
        --TODO: this relies on the cmdline state `getcmdline()`, somehow fix it and make it work in <C-r>=
        if _G.UA_DEV then assert(row==1) end
        return M.I.key_home..M.I.key_right:rep(M.I.len(vim.fn.getcmdline():sub(1,col-1)))
    else
        return M.keycode(('<cmd>call cursor(%s,%s)\r'):format(row or '"."',col))
    end
end
---@param cmd string
---@return string
function M._to_cmd(cmd,...)
    local arg={}
    for _,v in ipairs{...} do
        if v[1]=='string' then
            table.insert(arg,('%q'):format(v[2]))
        end
    end
    return M.keycode'<cmd>lua '..cmd:format(unpack(arg))..'\r'
end
M.tslang2lang={
    --These treesitter languages have multiple filetypes
    ---Category 0
    markdown_inline='markdown',
    haskell_persistent='haskell',
    ocaml_interface='ocaml',
    surface='elixir',
    ---Category 1
    markdown='markdown',
    glimmer='handlebars',
    html='html',
    ini='ini',
    javascript='javascript',
    make='make',
    muttrc='muttrc',
    scala='scala',
    sql='sql',
    tcl='tcl',
    tsx='typescriptreact',
    xml='xml',
    verilog='verilog',
    ---Category 2
    latex='tex',
    bash='sh',
    bibtex='bib',
    commonlisp='lisp',
    devicetree='dts',
    c_sharp='cs',
    diff='diff',
    eex='eelixir',
    embedded_template='eruby',
    facility='fsd',
    faust='dsp',
    gdshader='gdshader',
    git_config='gitconfig',
    git_rebase='gitrebase',
    godot_resource='gdresource',
    janet_simple='janet',
    linkerscript='ld',
    m68k='asm68k',
    poe_filter='poefilter',
    properties='jproperties',
    qmljs='qml',
    slang='slang',
    ssh_config='ssh_config',
    starlark='bzl',
    tlaplus='tla',
    udev='udevrules',
    uxntal='tal',
    v='v',
    vhs='tape',
    vento='vento',
    t32='trace32',
    textproto='pbtxt',
}
M._tslang2lang_single={
    markdown_inline=true,
    haskell_persistent=true,
    ocaml_interface=true,
    surface=true,
}
---@param o ua.filter
---@param opt {parser:vim.treesitter.LanguageTree?,tree:boolean?}?
---@return string
function M.get_filetype(o,opt)
    opt=opt or {}
    --TODO: opt.tree should (almost) always be configurable
    local range={o.rows-1,o.cols-1,o.rowe-1,o.cole-1}
    ---@param ltree vim.treesitter.LanguageTree
    local function lang_for_range(ltree)
        for _,child in pairs(ltree:children()) do
            for _,tree in pairs(child:trees()) do
                local tranges=tree:included_ranges(false)
                local trange={tranges[1][1],tranges[1][2],tranges[#tranges][3],tranges[#tranges][4]}
                if M.range_in_range(trange,range,true) then
                    return lang_for_range(child),true
                end
            end
        end
        return ltree:lang()
    end
    local tree=opt.tree~=false
    if not tree then return o.source.o.filetype end
    local parser=opt.parser or o.source.get_parser()
    if not parser then return o.source.o.filetype end
    local tslang,childlang=lang_for_range(parser)
    if not childlang then return o.source.o.filetype end
    return M.tslang2lang[tslang] or vim.treesitter.language.get_filetypes(tslang)[1] or tslang
end
---@param opt any|fun(o:ua.filter):any
---@param o ua.filter
function M.opt_eval(opt,o)
    if type(opt)=='function' then return opt(o) end
    return opt
end
---@param str string
---@param col number
---@return string
function M.get_char(str,col)
    if col>#str or col<=0 then return '' end
    return str:sub(
        vim.str_utf_start(str,col)+col,
        vim.str_utf_end(str,col)+col)
end
---@param o ua.info
---@param _coloff number? --TODO: temp
---@param _coloffe number? --TODO: temp
---@return ua.filter
function M.info_to_filter(o,_coloff,_coloffe)
    return {
        cols=o.col-(_coloff or 0),
        cole=o.col-(_coloffe or 0),
        line=o.line,
        lines=o.lines,
        rows=o.row,
        rowe=o.row,
        source=o.source,
        lsave=o.lsave,
    }
end
---@param filters table<string,table>
---@param o ua.info
---@param _coloff number? --TODO: temp
---@param _coloffe number? --TODO: temp
---@return boolean
function M.run_filters(filters,o,_coloff,_coloffe)
    local po=M.info_to_filter(o,_coloff,_coloffe)
    for filter,conf in pairs(filters) do
        if type(filter)=='number' then
            if not conf(po) then
                return false
            end
            goto continue
        end
        filter=filter:gsub('_[_0-9]*$','') --TODO: what pattern to use? --TODO: move this into a function for reuse. : TODO: ALSO: (maybe allow configuration of it) TODO: or just redesign the whole thing
        if conf.filter==false then goto continue end
        if not require('ultimate-autopair.filter.'..filter).call(setmetatable({conf=conf},{__index=po})) then
            return false
        end
        ::continue::
    end
    return true
end
---@param ft string
---@param option string
function M.ft_get_option(ft,option)
    if vim.o.filetype==ft then
        return vim.o[option]
    else
        return vim.filetype.get_option(ft,option)
    end
end
---@param range number[]
---@param contains_range number[]
---@param inclusive boolean?
---@return boolean
function M.range_in_range(range,contains_range,inclusive)
    --If crange is zero width then and only then inclusive influence the result
    --So [f(oo)] is always true and [foo()] is true depending on if inclusive is set
    local crange=contains_range
    if not inclusive and crange[1]==crange[3] and crange[2]==crange[4] then
        return (range[1]<crange[1] or (range[1]==crange[1] and range[2]<crange[2])) and
            (range[3]>crange[3] or (range[3]==crange[3] and range[4]>crange[4]))
    end
    return (range[1]<crange[1] or (range[1]==crange[1] and range[2]<=crange[2])) and
        (range[3]>crange[3] or (range[3]==crange[3] and range[4]>=crange[4]))
end
---@param o ua.filter
---@param str string
function M._HACK_parser_get_after_insert(o,str)
    local lines={}
    vim.list_extend(lines,o.source._lines)
    lines[o.rowe]=o.line:sub(1,o.cole-1)..str..o.line:sub(o.cole)
    o.cole=o.cole+1
    local parser=vim.treesitter.get_string_parser(table.concat(lines,'\n')..'\n',vim.treesitter.language.get_lang(o.source.o.filetype) or o.source.o.filetype)
    parser:parse({o.rows-1,o.rowe})
    return parser
end
return M
