--Description: pairs which mirror treesitter
--Example: <a>,</a>
--Problems:
---Work with everything else without breaking
----Fix: instead of initing extensions at init_time, test pair first and if is open/cloed, then init extensions with the spesific m value
---Work with get_pair_at_pos,is_open_pair
----Fix: refactor for spesific case
local M={}

return M
