# Future version

## Treesitter everywhere
Make use of treesitter everywhere, such as:
+ Pairs which are treesitter nodes. (for fastwarp)
+ Pairs which correspond to treesitter nodes (like if end statement). (for newline,backspace)
+ Extension alpha only working in text files/language tree `txt`/`md` and in nodes `comment`

## Better extensions
Make using extensions better, such as:
+ Pair specific extensions
+ extensions with their own config. (like disable ext.alpha in filetype lua)

# Maybe in the future versions

## Fast pair lookup
Currently the pair lookup uses a list of pairs and one needs to check against each pair is slow. One way that this will be mitigated is with caching (like filtering and caching `string` pairs). But that still leaves a loot of times where caching doesn't work, like `default.get_pair_by_pos`. For this one may use a different caching system which only saves the first and last characters of the pair. For example, the pair `<!--,-->` would be saved as `{'<':'<!--','-':['<!--','-->'],'>':'-->'}`.

## Caching
Currently there are a number of functions that are both an `O(n)` and called on every character which makes the plugin much slower on longer lines. So a cache should be implemented to solve this problem.

# Other plans
+ Survey about what features people want in auto-pairing plugins
