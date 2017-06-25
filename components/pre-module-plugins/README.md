# Pre-Module Plugins

Any .mak file will be automatically included in each _MODULE_ by Concerto during
the _PRELUDE_ definition.

This folder should contain plugins which are used by _MODULE_ concerto.mak files
_before_ their definitions. The _PRELUDE_ has been included by the time these makefiles
are read so the `_MODULE` definition is available but none of the module specific
variables are defined. If those are required, a post-module-plugins may be
appropriate.
