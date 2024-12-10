# treesitter
+ A better way to detect language in 0-width context
    + Check if the language may have injected languages
    + Get the top node (as in the node whose parent is the root node)
        + Does treesitter guarantee that this node doesn't use any information from siblings?
    + Get the text of the node
    + If text to long (more than 1000 lines or something (configurable!)), then skip
    + Insert random char into text
    + Get the language at the position
    + SOME OTHER IMPROVEMENTS???
