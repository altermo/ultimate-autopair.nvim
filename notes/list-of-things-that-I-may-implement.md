# mappings
+ [x] make key spesific fallback
+ [x] make it have the ability to use extensions
+ [x] make maps use filtering pair extensions
+ [x] `[{"| > <A-k> > [{""}]`
+ [ ] undo map for suround/autopair/...
## CR
+ [x] support
+ [x] auto add newline and tab `{|} > CR > {\n\t|\n}`
+ [x] respect the indentation level
+ [x] auto add pair `{| > CR > {\n|\n}`
+ [x] make falback behavior changable
+ [x] auto add multicharacter (markdown code block) `'''text|''' > CR > '''text\n\t|\n'''`)
+ [x] auto add multicharacter pairs `then| > CR > then\n|\nend`
+ [x] autocomplete integration
+ [x] make key spesific fallback
+ [x] auto add ; att the end of } in c when newline
+ [x] auto add pairs `{|}; > CR > {\n|\n};`
+ [x] auto add pairs `{|} foo > CR > {\n|\n} foo`
+ [x] auto add pairs `({|}) > CR > ({\n|\n})`
+ [x] make it have the ability to use extensions
+ [x] auto add even if text `{abc|} > CR > {abc\n|\n}`
+ [x] dont add multicharacter pairs `then|\nend > CR > then\n|\nend`
+ [x] auto add even if text `(|abc) > CR > (\n|abc\n)`
+ [x] make map use filtering pair extensions
+ [ ] auto add pairs `({| > CR > ({\n|\n})`
+ [ ] splitjoin plugin integration
## BS
+ [x] suport
+ [x] remove the pair `[|] > BS > |`
+ [x] remove the pair when pair filled `[|abc] > BS > |abc`
+ [x] remove the pair when pair empty `()| > BS > |`
+ [x] dont remove pair when cause not balance `[[|] > BS > [|]`
+ [x] make falback behavior changable
+ [x] remove the space in the pair `[ | ] > BS > [|]`
+ [x] remove the pair when multicharacter pair `/*|*/ > BS > |`
+ [x] filter string `'"'"|" > BS > '"'|`
+ [x] make key spesific fallback
+ [x] make it have the ability to use extensions
+ [x] remove the pair when multicharacter pair empty `/**/| > BS > |`
+ [x] remove the both newline in multiline pair `[\n|\n] > BS > [|]`
+ [x] remove the pair when pair with space `[ ]| > BS > |`
+ [x] remove the unbalanced space in the pair `[  | ] > BS > [ | ]`
+ [x] make map use filtering pair extensions
+ [x] remove the ambiguous pair when filled `"|abc" > BS > |abc`
+ [x] newline backspace for ambiguous pairs
+ [x] remove the unbalanced space in the pair `[ |  ] > BS > [ | ]`
+ [x] remove the unbalanced space in the pair `[  |] > BS > [|]`
+ [ ] don't remove the ambiguous pair when filled if alpha `a"|bc" > BS > a|bc"`
+ [ ] remove the pair when multicharacter pair filled `if bool then |code end > BS > |code`
+ [ ] remove the space when remove pair `[| text ] > BS > |text`
## space
+ [x] space `[|] > SP > [ | ]`
+ [x] smart space `[|text] > SP > [ |text ]`
+ [x] makdown don't add space `+ [|]` > `+ [ |]`
## fastwarp
+ [x] normal fastwarp `{|}[] > <A-e> > {[]|}`
+ [x] normal fastwarp `{}|foo > <A-e> > {foo|}`
+ [x] normal fastwarp `{foo|},bar > <A-e> > {foo,bar|}`
+ [x] normal fastwarp `{foo|}, > <A-e> > {foo,|}`
+ [x] normal fastwarp `{foo|},(bar) > <A-e> > {foo,(bar)|}`
+ [x] normal fastwarp `{(|),},bar > <A-e> > {(,|)},bar`
+ [x] fastwarp end  `<A-$>`
+ [x] fastwarp WORD `<A-E>`
+ [x] norma fastwarp multi line
+ [x] reverse fastwarp (+multiline)
+ [x] smart fastwarp end `(|)foo,bar,` > `<A-$>` > `(foo,bar|),`
+ [x] fastwarp no move cursor `(|)foo,bar > (|foo),bar`
+ [x] fastwarp cursor no move
+ [x] make ambiguous pairs have the ability to use fastwarp
+ [ ] one char fastwarp `(foo|),, > <A-L> > (foo,|),`
+ [ ] hop style fastwarp
+ [ ] fastwarp for starting pair/ambiguous pair `|(foo,bar)` > `foo,|(bar)`
+ [ ] fastwarp treesitter nodes
+ [ ] fastwarp ambiguous pair multiline
## extensions
+ [x] only filter inside or outside of string
+ [x] user defined rules
+ [x] filetype
+ [x] multiline mode with the indentation determening the block size
+ [x] disable for surtent cmdlinetypes
+ [x] treesitter integration for special blocks (aka strings)
+ [x] only filter inside or outside of comments and other user defined treesitter nodes
+ [x] make block filtering for inside/outside otpional `b|#a` > `b|\1` and `b#a|` > `b#a|` and not `\1#a|`
+ [x] filter escaped characters
+ [x] dont add pair `'` if previous is alphanumeric
+ [x] dont complete when previous is \ in string? `\| > [ > \[`
+ [x] `f > ' > f''`
+ [x] dont add pair if next is alphanumeric
+ [x] add the parens att end when logical `|"a" > [ > ["a"|]`
+ [x] dont add pair `'` in lisp
+ [x] quick hop end `[{|}] > ] > [{}]|`
+ [x] auto goto end if only space or newline `[text|  ] > ] > [text  ]|`
+ [x] auto goto end `[te|xt] > ] > [text]|`
+ [x] add the parens att end when logical `|{a} > [ > [|{a}]`
+ [x] filter ' in lisp not instring
+ [ ] markdown code block spesific behavior (like lisp code block)
+ [ ] markdown code block filter
+ [x] somehow changing default config internal pairs, like adding `fly=true` to `'` opt
+ [ ] user defined multiline as one (maybe using treesitter)
+ [ ] whole file detection (requires implementation of tsnode blocks)
+ [ ] extension in extension where they can return instead of continue
+ [ ] auto goto end if only space and remove `[text|  ] > ] > [text]|`
+ [ ] add the parens att end when logical multiline `|{\n} > ( > (|{\n})`
+ [ ] make rules use rule and not just check
# other
+ [x] `'a|b' > ' > 'a'|'b'`
+ [x] `[[|] > ] > [[]|] and not [[]|`
+ [x] lisp smart pair `"|" > ' > "'|'"`
+ [x] smart add `()|) > ) ())|)`
+ [x] auto skip multicharacter pair `/*|*/ > * > /**/|`
+ [x] open multicharacter-pair detector
+ [x] multicharacter pair `py ''' and md ````
+ [x] comment pairs `/*|*/`
+ [x] nonsymetrical comment pairs `<!--|-->`
+ [x] command-line integration
+ [x] make everything optional
+ [x] dot repeat
+ [x] abbreviation suport
+ [x] map repeating `vim.v.count` (maybe by making mappings {expr=true})
+ [x] replace mode integration
+ [x] better string filtering `'foo'|` > `'\1'|` and not `\1|`
+ [x] set up matrix room
+ [x] make config-types cond work with oinit and rule (while making standard)
+ [x] make extensions use other extensions
+ [x] make `default.start_pair` and `default.end_pair` use `pair.rule()`
+ [x] make wrappers for pair.fn functions (to avoid `pair.fn.is_start(pair.pair,pair.pair,...)`)
+ [x] make keymap desc stack instead of only setting one
+ [ ] terminal mode integration
+ [ ] implement windwp/nvim-autopairs like rules with configuration macros (and add refrence to windwp/nvim-autopairs)
+ [ ] implement most things defined in windwp/nvim-autopairs/wiki (and add refrence to windwp/nvim-autopairs)
+ [ ] test non pair parts (core,other config types...)
+ [ ] make everything work with multichar pair (fastwarp,space...)
+ [ ] abecodes/tabout.nvim like map
+ [ ] make use of treesitter stack of nodes at pos to filter instead of one node at pos
+ [ ] multicharacter pair not in string/other node
+ [x] auto escape extend in string?`'\|a' > ' > '\'|\'a'`
+ [ ] auto goto end if only newline and remove `[\n\t|\n] > ] > [\n]|` (requires multiline open_pair detection)
+ [ ] multicharacter pair with word delimiter `aAND ~= AND`
+ [ ] other keywords `if ... end`?
+ [ ] integration with (windwp/nvim-ts-autotag) to suport html tags
+ [ ] regex/wildcard multicharacter pair suport
+ [ ] with random text inbetween `if TEXT ... end`?
+ [ ] possibility of html tag suport
+ [ ] triple pair
+ [ ] newline autoclose only pairs (`if| > CR > if\n|\nend`)
+ [x] full utf8 suport
+ [ ] all mappings p set depending on mconf.p if not set
+ [ ] make a in_pair_map(pair,line): returns a table of bools (or maybe function) of whether in pair
+ [ ] buffer/InsertCharPre way of keybindings
+ [ ] auto set previous mapping as fallback
+ [ ] fastwarp to broad: make an option to not make it so (maybe: only hop over treesitter nodes/functions calls with dots and calls `M.fn(a)`)
+ [ ] object which contains a list of the pairs, like `(foo'')` > `{'(',"'","'",)}` pluss extra info (position,count,...)
+ [ ] caching values from open_pair functions
+ [ ] disable in comment (https://github.com/altermo/ultimate-autopair.nvim/issues/32)
+ [ ] in_tsnode_map: same as in_pair_map but for tsnodes
+ [ ] create and extension (or add a cmd to rule) which checks if in_pair/not_in_pair
+ [ ] make pairt.in_pair node detector recursively find if in node (option)
+ [ ] make tsnode extension recursively find if in node (option)
+ [ ] `default.matching_pair_start/end` get a pair of pairs `(|foo)` > `{(=1,)=5}`
+ [x] multiple same file maps (like `bs`) in one config with different options
+ [ ] make so that extensions can be not sourced (disabled) for spesific maps (like disableing ext-string for fastwarp)