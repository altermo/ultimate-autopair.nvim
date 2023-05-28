## Treesitter everywhere
Make use of treesitter everywhere, such as pairs which delimiters match the treesitter's node range.

## Remove deprecated
+ default.utils.get_pair is deprecated when relating top positional char
+ default.utils.get_type_opt to detect start/end pairs (including ambiguous) is deprecated.

## Multiline
Somehow make multiline feasible without making the plugin slow

## Caching
Currently there are a number of functions that are both an `O(n)` and called on every character which makes the plugin much slower on longer lines. So a cache should be implemented to solve this problem.
