---@alias ua._.str_buf string.buffer
local M={I={}}
M.I.len=vim.api.nvim_strwidth
---@generic T:string|string?
---@param str T
---@return T
function M.keycode(str)
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
    return M.I.key_bs:rep(pre or 1)..M.I.key_del:rep(pos or 0)
end
---@param col number
---@param row number?
---@return string
function M.key_pos_nodot(col,row)
    if not row then return M.I.key_i_ctrl_o..col..'|' end
    return M.I.key_i_ctrl_o..row..'gg'..M.I.key_i_ctrl_o..col..'|'
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
}
M._tslang2lang_single={
    markdown_inline=true,
    haskell_persistent=true,
    ocaml_interface=true,
    surface=true,
}
---@param o ua.filter
---@param opt {parser:vim.treesitter.LanguageTree?}?
---@return string
function M.get_filetype(o,opt)
    opt=opt or {}
    ---@param ltree vim.treesitter.LanguageTree
    local function lang_for_range(ltree,range)
        local query=vim.treesitter.query.get(ltree:lang(),'injections')
        if not query then return ltree:lang() end
        for _,tree in pairs(ltree:trees()) do
            for _,match,metadata in query:iter_matches(tree:root(),o.source.source,0,-1) do
                local lang=metadata['injection.language']
                if metadata['injection.parent'] then lang=ltree:lang() end
                local trange
                for id, node in pairs(match) do
                    local name=query.captures[id]
                    if name=='injection.language' then
                        lang=vim.treesitter.get_node_text(node,o.source.source)
                    elseif name=='injection.content' then
                        ---@diagnostic disable-next-line: undefined-field
                        trange={node:range()}
                    end
                end
                if (trange[1]<range[1] or (trange[1]==range[1] and trange[2]<=range[2])) and
                    (trange[3]>range[3] or (trange[3]==range[3] and trange[4]>=range[4])) then
                    local child=ltree:children()[lang]
                    if child then
                        return lang_for_range(child,range),true
                    else
                        return lang,true
                    end
                end
            end
        end
        return ltree:lang()
    end
    local tree=true --TODO: local tree=o.opt.treesitter
    if not tree then return o.source.o.filetype end
    local parser=opt.parser or o.source.get_parser()
    if not parser then return o.source.o.filetype end
    local range={o.rows-1,o.cols-1,o.rowe-1,o.cole-1}
    local tslang,childlang=lang_for_range(parser,range)
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
---@param filters table<string,table>
---@param o ua.info
---@param _coloff number? --TODO: temp
---@param _coloffe number? --TODO: temp
---@return boolean
function M.run_filters(filters,o,_coloff,_coloffe)
    local po={
        cols=o.col-(_coloff or 0),
        cole=o.col-(_coloffe or 0),
        line=o.line,
        lines=o.lines,
        rows=o.row,
        rowe=o.row,
        source=o.source,
        lsave=o._lsave,
        _o=o, --TODO: temp (only for debugging)
    }
    for filter,conf in pairs(filters) do
        filter=filter:gsub('_*%d*$','')
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
    local crange=contains_range
    --TODO: if crange is zero width then and only then have inclusive influence the result
    --So [f(oo)] is always true and [foo()] is true depending on if inclusive is set
    if inclusive then
        return (range[1]<crange[1] or (range[1]==crange[1] and range[2]<=crange[2])) and
            (range[3]>crange[3] or (range[3]==crange[3] and range[4]>=crange[4]))
    end
    return (range[1]<crange[1] or (range[1]==crange[1] and range[2]<crange[2])) and
        (range[3]>crange[3] or (range[3]==crange[3] and range[4]>crange[4]))
end
---@param o ua.filter
---@param str string
function M._HACK_parser_get_after_insert(o,str)
    local lines={}
    vim.list_extend(lines,o.source._lines)
    lines[o.rowe]=o.line:sub(1,o.cole-1)..str..o.line:sub(o.cole)
    o.cole=o.cole+1
    local parser=vim.treesitter.get_string_parser(table.concat(lines,'\n'),vim.treesitter.language.get_lang(o.source.o.filetype) or o.source.o.filetype)
    parser:parse({o.rows-1,o.rowe})
    return parser
end
return M
