+ [x] dont add pair `'` if previous is alphanumeric
+ [x] dont complete when previous is \ in string? `\| > [ > \[`
+ [x] `'a|b' > ' > 'a'|'b'`
+ [x] `f > ' > f''`
+ [x] `[[|] > ] > [[]|] and not [[]|`
+ [x] dont add pair if next is alphanumeric
+ [x] add the parens att end when logical `|"a" > [ > ["a"|]`
+ [x] auto escape extend in string?`'\|a' > ' > '\'|\'a'`
+ [x] dont add pair `'` in lisp
+ [x] lisp smart pair `"|" > ' > "'|'"`
+ [x] quick hop end `[{|}] > ] > [{}]|`
+ [x] auto goto end if only space or newline `[text|  ] > ] > [text  ]|`
+ [x] smart add `()|) > ) ())|)`
+ [ ] auto goto end `[te|xt] > ] > [text]|`
+ [ ] auto skip multicharacter pair `/*|*/ > * > /**/|`
+ [ ] auto goto end if only space and remove `[text|  ] > ] > [text]|`
+ [ ] open multicharacter-pair detector
+ [ ] auto goto end if only newline and remove `[\n\t|\n] > ] > [\n]|`
+ [ ] `[{| > ] > [{}]|`
+ [ ] add the parens att end when logical `|{a} > [ > [|{a}]`
