# Copyright (C) 2010 Erik Rainey
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

EMPTY:=
SPACE:=$(EMPTY) $(EMPTY)

# Take the Makefile list and remove prelude and finale includes
# @note MAKEFILE_LIST is an automatic variable!
ifeq ($(HOST_OS),Windows_NT)
ALL_MAKEFILES := $(filter %\$(SUBMAKEFILE),$(MAKEFILE_LIST))
else
ALL_MAKEFILES := $(filter %/$(SUBMAKEFILE),$(MAKEFILE_LIST))
endif
#$(info ALL_MAKEFILES=$(ALL_MAKEFILES))

# Take the resulting list and remove the pathing and Makefile each entry and
# then you have the modules list.

# get this makefile
THIS_MAKEFILE := $(lastword $(ALL_MAKEFILES))
#$(info THIS_MAKEFILE=$(THIS_MAKEFILE))
#$(info HOST_ROOT=$(HOST_ROOT))

# Remove the $(SUBMAKEFILE) to get the path
ifeq ($(HOST_OS),Windows_NT)
# This is a bear on Windows!
_MAKEPATH := $(dir $(THIS_MAKEFILE))
#$(info PATH=$(_MAKEPATH))
_FULLPATH := $(lastword $(subst :,$(SPACE),$(_MAKEPATH)))
#$(info FULL=$(_FULLPATH))
_BASEPATH := $(lastword $(subst :,$(SPACE),$(subst /,\,$(HOST_ROOT))))
#$(info BASE=$(_BASEPATH))
_MODPATH  := $(subst $(_BASEPATH),,$(_FULLPATH))
#$(info PATH=$(_MODPATH))
# now in the form of \...\...\ remove the outer \'s
_PARTS   := $(strip $(subst \,$(SPACE),$(_MODPATH)))
#$(info PARTS=$(_PARTS))
_MODPATH := $(subst $(SPACE),\,$(_PARTS))
#$(info STRIPPED PATH=$(_MODPATH))
else
_MODPATH := $(subst /$(SUBMAKEFILE),,$(THIS_MAKEFILE))
endif

ifdef BUILD_DEBUG
$(info _MODPATH=$(_MODPATH))
endif

ifeq ($(_MODPATH),)
$(error $(THIS_MAKEFILE) failed to get module path)
endif

ifeq ($(HOST_OS),Windows_NT)
_MODDIR := $(lastword $(subst \,$(SPACE),$(_MODPATH)))
else
_MODDIR := $(lastword $(subst /,$(SPACE),$(_MODPATH)))
endif

# If we're calling this from our directory we need to figure out the path
ifeq ($(_MODDIR),./)
ifeq ($(HOST_OS),Windows_NT)
_MODDIR := $(lastword $(subst /, ,$(abspath .)))
else
_MODDIR := $(lastword $(subst /, ,$(abspath .)))
endif
endif

#$(info _MODDIR=$(_MODDIR))

# if the makefile didn't define the module name, use the directory name
ifeq ($(_MODULE),)
_MODULE=$(_MODDIR)
endif

# if there's no module name, this isn't going to work!
ifeq ($(_MODULE),)
$(error Failed to create module name!)
endif

# Print some info to show that we're processing the makefiles
ifdef BUILD_DEBUG
$(info Adding Module $(_MODULE) to MODULES)
endif

# Add the current module to the modules list
MODULES+=$(_MODULE)

# Define the Path to the Source Files (always use the directory) and Header Files
$(_MODULE)_SDIR := $(HOST_ROOT)/$(_MODPATH)
$(_MODULE)_IDIRS:= $($(_MODULE)_SDIR)

# Route the output for each module into it's own folder
$(_MODULE)_ODIR := $(TARGET_OUT)/module_$(_MODULE)
$(_MODULE)_TDIR := $(TARGET_OUT)

# Set the initial linking directories to the target directory
$(_MODULE)_LDIRS := $($(_MODULE)_TDIR)

# Set the install directory if it's not set already
ifndef INSTALL_LIB
$(_MODULE)_INSTALL_LIB := $($(_MODULE)_TDIR)
else
$(_MODULE)_INSTALL_LIB := $(INSTALL_LIB)
endif
ifndef INSTALL_BIN
$(_MODULE)_INSTALL_BIN := $($(_MODULE)_TDIR)
else
$(_MODULE)_INSTALL_BIN := $(INSTALL_BIN)
endif
ifndef INSTALL_INC
$(_MODULE)_INSTALL_INC := $($(_MODULE)_TDIR)/include
else
$(_MODULE)_INSTALL_INC := $(INSTALL_INC)
endif

# Define a ".gitignore" file which will help in making sure the module's output
# folder always exists.
%.gitignore:
ifeq ($(BUILD_DEBUG),1)
	$(PRINT) Creating Folder $(dir $@)
endif
	-$(Q)$(MKDIR) $(call PATH_CONV,$(dir $@))
ifeq ($(BUILD_DEBUG),1)
	$(PRINT) Touching $@
endif
	-$(Q)$(TOUCH) $(call PATH_CONV,$@)

dir:: $($(_MODULE)_ODIR)/.gitignore

# Clean out common vars
ENTRY :=
DEFS :=
CFLAGS :=
LDFLAGS :=
STATIC_LIBS :=
SHARED_LIBS :=
SYS_STATIC_LIBS :=
SYS_SHARED_LIBS :=
IDIRS :=
LDIRS :=
CSOURCES :=
CPPSOURCES :=
ASSEMBLY :=
JSOURCES :=
JAVA_LIBS :=
TARGET :=
TARGETTYPE :=
BINS :=
INCS :=
INC_SUBPATH :=
HEADERS :=
DEFFILE :=

# Define convenience variables
SDIR := $($(_MODULE)_SDIR)
TDIR := $($(_MODULE)_TDIR)
ODIR := $($(_MODULE)_ODIR)

# Pull in the definitions which will be redefined for this makefile
include $(CONCERTO_ROOT)/definitions.mak
