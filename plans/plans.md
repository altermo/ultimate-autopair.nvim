## What this file is?
This file contains notes about the plugin.
## The incorrect documentation
Cause of how frequent the changes (and whole rewrites) are makes it pretty hard to write documentation which doesn't instantly become outdated.
## The `maps` use of extensions
The lua files inside `maps` which use extensions are pretty messy. For some of them, the order in which the extensions are executed is "dependent on table order", causing extensions to be executed "randomly". For other files which use extensions, where the order is important, the extension functions are put into a table(list) without names, making it harder to know which function is which extension. There is also the problem of that the files can't use user defined extensions easily.
