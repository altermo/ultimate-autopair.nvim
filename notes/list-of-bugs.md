+ [ ] doesn't filter alpha `don't |` > `'` > `don't '`
+ [ ] abbreviation not updating line `iab f foo(` `f` > `'` > `foo(')`
+ [ ] `'a'"b"` is filterd as `'"` instead of `''""` using treesitter
+ [ ] `'"','"|\n'` > `"` > `'"','""|"\n'`
+ [ ] ext.utf8 with ext.string causes a lot of problems
