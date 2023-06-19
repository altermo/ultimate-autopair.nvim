## Treesitter everywhere
Make use of treesitter everywhere, such as pairs which delimiters match the treesitter's node range.

## Multiline
Somehow make multiline feasible without making the plugin slow

## Caching
Currently there are a number of functions that are both an `O(n)` and called on every character which makes the plugin much slower on longer lines. So a cache should be implemented to solve this problem.

## A total rework for not detecting pairs?
Currently the only way to not detect pairs are: filtering and `rule()`. This is a problem as there is no easy way to for example not detect quote which is presided by an alpha (`a'`), as the only current way is to check if there's a pair after alpha and check if the pair has the option alpha and then filter. 

## Fast pair lookup
Currently the pair lookup uses a list of pairs and one needs to check against each pair is slow. One way that this will be mitigated is with caching (like filtering and caching `string` pairs). But that still leaves a loot of times where caching doesn't work, like `default.get_pair_by_pos`. For this one may use a different caching system which only saves the first and last characters of the pair. For example, the pair `<!--,-->` would be saved as `{'<':'<!--','-':['<!--','-->'],'>':'-->'}`.
