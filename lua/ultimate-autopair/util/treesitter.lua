local M={}

M.tslang2lang={
  ---Last updated: 2026-03-13
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
  json='json',
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
  ocaml_interface='ocaml',
  jinja_inline='jinja',
  nim_format_string='nim',
  ---- Special syntax for checkhealth to ignore them
  [' markdown_inline']='',
  [' ocaml_interface']='',
  [' jinja_inline']='',
  [' nim_format_string']='',
}

---@param tslang string
---@return string
function M.tslang_to_ft(tslang)
  return M.tslang2lang[tslang] or vim.treesitter.language.get_filetypes(tslang)[1] or tslang
end

--TODO
---@param con ua.context
---@param range Range4
---@param cond fun(node:TSNode):boolean
---@return TSNode?
function M.find_node(con,range,cond)
--   local cache=con.cache[M.in_tsnode]
  local parser=con.parser
  while parser do
    local node=parser:named_node_for_range(range)
    -- local ids={}
    while node do
      -- if cache[node:id()]~=nil then
      --   return cache[node:id()] or nil
      -- end
      node=node:parent()
      if not node then
        break
      end
      -- table.insert(ids,node:id())
      if cond(node) then
        -- for _,id in ipairs(ids) do
        --   cache[id]=node
        -- end
        return node
      end
    end
    -- for _,id in ipairs(ids) do
    --   cache[id]=false
    -- end
    parser=M.get_tslang(con,range,parser)
  end
end

---@param con ua.context
---@param range Range4
---@param ltree vim.treesitter.LanguageTree
---@return vim.treesitter.LanguageTree?
function M.get_tslang(con,range,ltree)
  return {con,range,ltree} and nil
end

return M
