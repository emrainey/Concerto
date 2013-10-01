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

ifeq ($(SHOW_MAKEDEBUG),1)
$(info _MODPATH=$(_MODPATH))
endif

ifeq ($(_MODPATH),)
$(error $(THIS_MAKEFILE) failed to get module path)
endif

ifeq ($(HOST_OS),Windows_NT)
_MODDIR := $(subst \,.,$(_MODPATH))
else
_MODDIR := $(subst /,.,$(_MODPATH))
endif

# If we're calling this from our directory we need to figure out the path
ifeq ($(_MODDIR),./)
ifeq ($(HOST_OS),Windows_NT)
_MODDIR := $(lastword $(subst \,$(SPACE),$(abspath .)))
else
_MODDIR := $(lastword $(subst /,$(SPACE),$(abspath .)))
endif
endif

ifeq ($(SHOW_MAKEDEBUG),1)
$(info _MODDIR=$(_MODDIR))
endif

# if the makefile didn't define the module name, use the directory name
ifeq ($(BUILD_MULTI_PROJECT),1)
ifneq ($(_MODULE),)
_MODULE:=$(_MODDIR)+$(_MODULE)
else
_MODULE:=$(_MODDIR)
endif
else ifeq ($(_MODULE),)
_MODULE:=$(_MODDIR)
endif

# if there's no module name, this isn't going to work!
ifeq ($(_MODULE),)
$(error Failed to create module name!)
endif

_MODULE_NAME := $(_MODULE)

ifneq ($(TARGET_COMBOS),)
# Append differentiation if in multi-core mode
_MODULE := $(_MODULE).$(TARGET_PLATFORM).$(TARGET_OS).$(TARGET_CPU).$(TARGET_BUILD)
endif

# Print some info to show that we're processing the makefiles
ifeq ($(SHOW_MAKEDEBUG),1)
$(info Adding Module $(_MODULE) to MODULES)
endif

# IF there is a conflicting _MODULE, error
$(if $(filter $(_MODULE),$(MODULES)),$(error MODULE $(_MODULE) already defined in $(MODULES)!))

# Add the current module to the modules list
MODULES += $(_MODULE)

# Define the Path to the Source Files (always use the directory) and Header Files
$(_MODULE)_SDIR := $(HOST_ROOT)/$(_MODPATH)
$(_MODULE)_IDIRS:= $($(_MODULE)_SDIR)

# Route the output for each module into it's own folder
$(_MODULE)_ODIR := $(TARGET_OUT)/module/$(_MODULE_NAME)
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
ifeq ($(SHOW_MAKEDEBUG),1)
	$(PRINT) Creating Folder $(dir $@)
endif
	-$(Q)$(MKDIR) $(call PATH_CONV,$(dir $@))
ifeq ($(SHOW_MAKEDEBUG),1)
	$(PRINT) Touching $@
endif
	-$(Q)$(TOUCH) $(call PATH_CONV,$@)

dir:: $($(_MODULE)_ODIR)/.gitignore

# Clean out the concerto.mak variables
_MODULE_VARS := ENTRY DEFS CFLAGS LDFLAGS STATIC_LIBS SHARED_LIBS SYS_STATIC_LIBS
_MODULE_VARS += SYS_SHARED_LIBS IDIRS LDIRS CSOURCES CPPSOURCES ASSEMBLY JSOURCES
_MODULE_VARS += KCSOURCES JAVA_LIBS TARGET TARGETTYPE BINS INCS INC_SUBPATH HEADERS
_MODULE_VARS += MISRA_RULES LINKER_FILES DEFFILE PDFNAME TESTCASE TESTOPTS VERSION
_MODULE_VARS += SKIPBUILD XDC_GOALS XDC_SUFFIXES XDC_PROFILES XDC_ARGS NOT_PKGS XDC_PACKAGES 
_MODULE_VARS += USE_GLUT USE_OPENCL

_MODULE_VARS := $(sort $(_MODULE_VARS))

ifeq ($(SHOW_MAKEDEBUG),1)
$(info _MODULE_VARS=$(_MODULE_VARS))
endif

# Clear out all the variables
ifeq ($(MAKE_VERSION),3.82)
$(foreach mvar,$(_MODULE_VARS),$(eval undefine $(mvar)))
else
$(foreach mvar,$(_MODULE_VARS),$(eval $(mvar):=$(EMPTY)))
endif

# Clearing all "MODULE_%" variables
$(foreach mod,$(filter MODULE_%,$(.VARIABLES)),$(eval $(mod):=$(EMPTY)))

# Define convenience variables
SDIR := $($(_MODULE)_SDIR)
TDIR := $($(_MODULE)_TDIR)
ODIR := $(call PATH_CONV,$($(_MODULE)_ODIR))

# Pull in the definitions which will be redefined for this makefile
include $(CONCERTO_ROOT)/definitions.mak
