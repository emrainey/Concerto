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

# Define all but don't do anything with it yet.
.PHONY: all
all::

# Define our pathing
HOST_ROOT?=$(abspath .)
$(info HOST_ROOT=$(HOST_ROOT))

BUILD_FOLDER?=concerto
CONCERTO_ROOT?=$(HOST_ROOT)/$(BUILD_FOLDER)

include $(CONCERTO_ROOT)/os.mak
include $(CONCERTO_ROOT)/machine.mak
include $(CONCERTO_ROOT)/target.mak
include $(CONCERTO_ROOT)/shell.mak

# Define the prelude and finale files so that SUBMAKEFILEs know what they are
# And if the users go and make -f concerto.mak then it will not work right.
PRELUDE := $(CONCERTO_ROOT)/prelude.mak
FINALE  := $(CONCERTO_ROOT)/finale.mak
SUBMAKEFILE := concerto.mak

# Remove the implicit rules for compiling.
.SUFFIXES:

# Allows the commands to be printed out when invoked
ifeq ($(BUILD_DEBUG),1)
Q=
else
Q=@
endif

# Initialize Build Variables
SKIPBUILD:=

ifeq ($(NO_OPTIMIZE),1)
TARGET_BUILD:=debug
else
TARGET_BUILD:=release
endif
$(info TARGET_BUILD=$(TARGET_BUILD))

# If no directories were specified, then assume "source"
DIRECTORIES?=source

# Find all the Makfiles in the subfolders, these will be pulled in to make
ifeq ($(HOST_OS),Windows_NT)
TARGET_MAKEFILES:=$(foreach d,$(DIRECTORIES),$(shell cd $(d) && cmd.exe /C dir /b /s $(SUBMAKEFILE)))
else
TARGET_MAKEFILES:=$(foreach d,$(DIRECTORIES),$(shell find $(d)/ -name $(SUBMAKEFILE)))
endif
ifdef BUILD_DEBUG
$(info TARGET_MAKEFILES=$(TARGET_MAKEFILES))
endif

# Create the MODULES list by parsing the makefiles.
MODULES:=
include $(TARGET_MAKEFILES)
$(info MODULES=$(MODULES))

ifndef NO_TARGETS
.PHONY: all dir depend build install uninstall clean clean_target targets scrub vars test

depend::

all:: build

build:: dir depend

install:: build

uninstall::

targets::
	@echo TARGETS=$(MODULES)

out::
ifeq ($(HOST_OS),Windows_NT)
	@echo TARGET_OUT=$(HOST_ROOT)\out\$(TARGET_CPU)\$(TARGET_OS)
else
	@echo TARGET_OUT=$(HOST_ROOT)/out/$(TARGET_CPU)/$(TARGET_OS)
endif

scrub::
ifeq ($(HOST_OS),Windows_NT)
	@echo [ROOT] Deleting $(HOST_ROOT)\out\$(TARGET_OS)\$(TARGET_CPU)
	-$(Q)$(CLEANDIR) $(call PATH_CONV,$(HOST_ROOT)/out/$(TARGET_OS)/$(TARGET_CPU))
else
	@echo [ROOT] Deleting $(HOST_ROOT)/out/$(TARGET_OS)/$(TARGET_CPU)
	-$(Q)$(CLEANDIR) $(HOST_ROOT)/out/$(TARGET_OS)/$(TARGET_CPU)
endif

vars:: $(foreach mod,$(MODULES),$(mod)_vars)
	@echo HOST_ROOT=$(HOST_ROOT)
	@echo HOST_OS=$(HOST_OS)
	@echo HOST_COMPILER=$(HOST_COMPILER)
	@echo TARGET_CPU=$(TARGET_CPU)
	@echo MAKEFILE_LIST=$(MAKEFILE_LIST)
	@echo TARGET_MAKEFILES=$(TARGET_MAKEFILES)

test:: $(foreach mod,$(MODULES),$(mod)_test)
	@echo Executing Unit tests
endif

