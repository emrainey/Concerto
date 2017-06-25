# Post-Module Plugins

Any .mak file will be automatically included in each _MODULE_ by Concerto during
the _FINALE_ definition.

This folder should contain plugins which are used by _MODULE_ concerto.mak files
_after_ their definitions. The _FINALE_ has been included by the time these makefiles
are read so all `$(_MODULE)_*` definitions are available.

This folder will frequently contain plugins which modify the module variables for build reasons.
