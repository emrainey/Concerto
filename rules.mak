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

SHELL = /bin/sh

# Basic definitions for parsing and tokenizing
EMPTY:=
SPACE:=$(EMPTY) $(EMPTY)
COMMA:=$(EMPTY),$(EMPTY)
TOKENS=$(subst :,$(SPACE),$(1))

# Define all but don't do anything with it yet.
.PHONY: all
all::

# Remove the implicit rules for compiling.
.SUFFIXES:

# Define our pathing and default variable values
HOST_ROOT ?= $(abspath .)
BUILD_FOLDER ?= concerto
CONCERTO_ROOT ?= $(HOST_ROOT)/$(BUILD_FOLDER)
BUILD_OUTPUT ?= out
BUILD_TARGET ?= $(CONCERTO_ROOT)/target.mak
BUILD_PLATFORM ?= $(CONCERTO_ROOT)/platform.mak
DIRECTORIES ?= source
ifeq ($(NO_OPTIMIZE),1)
TARGET_BUILD?=debug
else
TARGET_BUILD?=release
endif

# Define the prelude and finale files so that SUBMAKEFILEs know what they are
# And if the users go and make -f concerto.mak then it will not work right.
PRELUDE := $(CONCERTO_ROOT)/prelude.mak
FINALE  := $(CONCERTO_ROOT)/finale.mak
SUBMAKEFILE := concerto.mak

# Allows the commands to be printed out when invoked
ifeq ($(BUILD_DEBUG),1)
Q:=
else
Q:=@
endif

include $(CONCERTO_ROOT)/os.mak
include $(CONCERTO_ROOT)/machine.mak
include $(CONCERTO_ROOT)/shell.mak
include $(CONCERTO_ROOT)/scm.mak

# Check for COMBOS, if none existed make a single COMBO
TARGET_COMBOS ?= PC:$(HOST_OS):$(HOST_CPU):0:$(TARGET_BUILD):$(HOST_COMPILER)

# Find all the Makfiles in the subfolders, these will be pulled in to make
ifeq ($(HOST_OS),Windows_NT)
TARGET_MAKEFILES:=$(foreach d,$(DIRECTORIES),$(shell cd $(d) && cmd.exe /C dir /b /s $(SUBMAKEFILE)))
else
TARGET_MAKEFILES:=$(foreach d,$(DIRECTORIES),$(shell find $(d)/ -name $(SUBMAKEFILE)))
endif

# These variables will be appended by each new submakefile included in the combo
MODULES:=
CONCERTO_TARGETS :=
TESTABLE_MODULES :=

# Define a macro to make the output target path
MAKE_OUT = $(1)/$(BUILD_OUTPUT)/$(TARGET_OS)/$(TARGET_CPU)/$(TARGET_BUILD)

# Define a macro to remove a combo from the combos list if it matches a value
FILTER_COMBO = $(foreach combo,$(TARGET_COMBOS),$(if $(filter $(1),$(subst :, ,$(combo))),$(combo)))
FILTER_OUT_COMBO = $(foreach combo,$(TARGET_COMBOS),$(if $(filter $(1),$(subst :, ,$(combo))), ,$(combo))) 

# Macro to include the combo rules
define CONCERTO_BUILD
include $(CONCERTO_ROOT)/combo.mak
endef

include $(CONCERTO_ROOT)/combo_filters.mak

# Multi-core Build (Single Core is degenerative)
# This actually invokes the above macro
$(foreach TARGET_COMBO,$(TARGET_COMBOS),$(eval $(call CONCERTO_BUILD)))

ifndef NO_TARGETS
.PHONY: all dir depend build install uninstall clean clean_target outputs targets scrub vars test docs clean_docs pdf

depend::

all:: build

build:: dir depend

install:: build

uninstall::

outputs:: $(foreach mod,$(MODULES),$(mod)_output)

targets::
	$(PRINT) MODULES=$(MODULES)
	$(PRINT) TARGETS=$(CONCERTO_TARGETS)

scrub::
	$(PRINT) Deleting $(BUILD_OUTPUT)
	-$(Q)$(CLEANDIR) $(call PATH_CONV,$(BUILD_OUTPUT))

vars:: $(foreach mod,$(MODULES),$(mod)_vars)
	$(PRINT) HOST_ROOT=$(HOST_ROOT)
	$(PRINT) HOST_CPU=$(HOST_CPU)
	$(PRINT) HOST_FAMILY=$(HOST_FAMILY)
	$(PRINT) HOST_OS=$(HOST_OS)
	$(PRINT) MAKEFILE_LIST=$(MAKEFILE_LIST)
	$(PRINT) TARGET_MAKEFILES=$(TARGET_MAKEFILES)

test:: $(foreach mod,$(TESTABLE_MODULES),$(mod)_test)

todo:
	$(Q)fgrep -Rni TODO $(HOST_ROOT) --exclude-dir=.git \
									 --exclude-dir=.svn \
									 --exclude-dir=docs \
									 --exclude-dir=$(BUILD_FOLDER) \
									 --exclude-dir=$(BUILD_OUTPUT)

bugs:
	$(Q)fgrep -Rni BUGS $(HOST_ROOT) --exclude-dir=.git \
									 --exclude-dir=.svn \
									 --exclude-dir=docs \
									 --exclude-dir=$(BUILD_FOLDER) \
									 --exclude-dir=$(BUILD_OUTPUT)

endif
