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
+ [x] auto add pairs `{|}; > CR > {\n|\n};`
+ [x] auto add pairs `{|} foo > CR > {\n|\n} foo`
+ [x] auto add pairs `({|}) > CR > ({\n|\n})`
+ [x] make it have the ability to use extensions
+ [x] auto add even if text `{abc|} > CR > {abc\n|\n}`
+ [x] dont add multicharacter pairs `then|\nend > CR > then\n|\nend`
+ [x] auto add even if text `(|abc) > CR > (\n|abc\n)`
+ [x] make map use filtering pair extensions
+ [x] auto add pairs `({| > CR > ({\n|\n})`
+ [ ] splitjoin plugin integration
+ [ ] auto add ; att the end of } in c when newline and in node...
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
+ [x] don't remove the ambiguous pair when filled if alpha `a'|bc' > BS > a|bc'`
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
+ [x] fastwarp ambiguous pair multiline
+ [ ] hop style fastwarp
+ [ ] fastwarp for starting pair/ambiguous start pair `|(foo,bar)` > `foo,|(bar)`
+ [ ] fastwarp treesitter nodes
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
+ [x] somehow changing default config internal pairs, like adding `fly=true` to `'` opt
+ [x] markdown code block spesific behavior (like lisp code block)
+ [x] whole file detection (requires implementation of tsnode blocks)
+ [x] make rules use `filter` and not just `check`
+ [x] markdown code block filter
+ [x] user defined multiline as one using treesitter
+ [x] add the parens att end when logical multiline `|{\n} > ( > (|{\n})`
+ [ ] extension in extension where they can return instead of continue
+ [ ] auto goto end if only space and remove `[text|  ] > ] > [text]|`
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
+ [x] multicharacter pair not in string/other node
+ [x] auto escape extend in string?`'\|a' > ' > '\'|\'a'`
+ [x] full utf8 suport
+ [x] make use of treesitter stack of nodes at pos to filter instead of one node at pos
+ [x] abecodes/tabout.nvim like map
+ [x] disable in comment (https://github.com/altermo/ultimate-autopair.nvim/issues/32)
+ [x] create an extension (or add a cmd to cond) which checks if in_pair/not_in_pair
+ [x] make tsnode extension recursively find if in node (option)
+ [x] `default.matching_pair_start/end` get a pair of pairs `(|foo)` > `{(=1,)=5}`
+ [x] multiple same file maps (like `bs`) in one config with different options
+ [x] multicharacter pair with word delimiter `aAND ~= AND`
+ [x] fastwarp to broad: make an option to not make it so (maybe: functions calls with dots and calls `M.fn(a)`)
+ [x] newline autoclose only pairs (`if| > CR > if\n|\nend`)
+ [x] all mappings p set depending on mconf.p if not set
+ [x] make core support multiple modes `M.modes={'c','i',...}`
+ [x] make test not use neovim exec and instead direct function call
+ [x] refactor most of the code and add type annotasions
+ [x] did `rules` just kinda become useless with `filter`?
+ [x] move things like open_pair.start_pair_can_check to maybe m.fn or other...
+ [x] own au-group (each instance different au-group)
+ [x] make every extension option to a maybe function
+ [ ] add reverse tabout
+ [ ] terminal mode integration
+ [ ] <s>implement windwp/nvim-autopairs like rules with configuration macros (and add refrence to windwp/nvim-autopairs)</s>
+ [ ] <s>implement most things defined in windwp/nvim-autopairs/wiki (and add refrence to windwp/nvim-autopairs)</s>
+ [ ] test non pair parts (core,other profile types...)
+ [ ] ¿is_implemented? make everything work with multichar pair (fastwarp,space...)
+ [ ] auto goto end if only newline and remove `[\n\t|\n] > ] > [\n]|` (requires multiline open_pair detection)
+ [ ] other keywords `if ... end`?
+ [ ] integration with (windwp/nvim-ts-autotag) to suport html tags
+ [ ] regex/wildcard multicharacter pair suport
+ [ ] with random text inbetween `if TEXT ... end`?
+ [ ] possibility of html tag suport
+ [ ] triple pair
+ [ ] core option to have buffer/InsertCharPre way of keybindings
+ [ ] auto set previous mapping as fallback
+ [ ] fastwarp hop over treesitter nodes
+ [ ] <s>object which contains a list of the pairs, like `(foo'')` > `{'(',"'","'",)}` pluss extra info (position,count,...)</s>
+ [ ] <s>caching values from open_pair functions</s>
+ [ ] make so that extensions can be not sourced (disabled) for spesific maps (like disableing ext-string for fastwarp)
+ [ ] core option
+ [ ] <s>smartly cache in_pair so that it only needs to max loop the hole line once</s>
+ [ ] create object of things for better in checking (`{obj={string={tsnode('string')},comment={tsnode('comment'),regex('\\s*/\\*.*\\*/')}}}`)
+ [ ] utf8 pairs
+ [ ] <s>maybe add unbalanced detection into filter</s>
+ [ ] maybe implement `{'(',')',id=1}` for use in cond and other
+ [ ] config scope pairs (aka pairs which only are detected by other function in same config) (not profile/global scope pairs)
+ [ ] filetype: recursive ts-ft: if in luadoc, wanted lua.
+ [ ] make ternary operations use `''` as nil
+ [ ] multiple core instances (with each having its own id?)
+ [ ] if map_opt is set to dict, then enable, else disable
+ [ ] multiline for some filetypes (multiline=function() return ... end)
+ [ ] filter early return or caching? (?it wont change between passes)
+ [ ] seperate interactive tests to their own healt.start
+ [ ] cache
    + [ ] instead of caching node:id, cache also range (cause gettsnode is slow)...
+ [ ] make mapping doc like ext doc
+ [ ] test make multichar input work without interactive (interactive is expensive)
+ [ ] fastwarp multi pair `f(g(|))h` > `f(g(|h))
+ [ ] be able to fastwarp things like html tags, which are not autopaird
+ [ ] nvim-surround like features
+ [ ] have the ability to disable langtree filter: if tree.root, go to parent langtree
+ [ ] somehow make collitions not happen
+ [ ] option to disable open pair detecting backspace/newline/insert
+ [ ] be able to create non pair mappings which work with the pair api
+ [ ] use spesific addons; like work for nvim-treesitter-endwise/add quote after list
+ [ ] use unpack in config to easely add new pairs, like endwise pairs
+ [ ] extension.fly multiline
