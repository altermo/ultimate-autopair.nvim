+ [ ] abbreviation not updating line `iab f foo(` `f` > `'` > `foo(')`
+ [ ] some things presume order in table, which causes bugs ones in a while
    + [ ] can happen with cr.autoclose
    + [ ] can happen with fastwarp.filter_string, here are some of the errors:
        + { '(|")")', "\1", '(|)")"', {c = {fastwarp = {filter_string = true}},ts = true} } failed, actuall result: '(|"))"'
        + { '(|")")', "\1", '(|)")"', {c = {fastwarp = {filter_string = true}},ts = true} } failed, actuall result: '(€ü\bE|")")'
        + { '(|")")', "\1", '(|)")"', {c = {fastwarp = {filter_string = true}},ts = true} } failed, actuall result: '(|")")'
