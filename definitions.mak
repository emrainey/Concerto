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

# List all files of type $(1) in a module subdirectory $(2) and its subdirectories
# The list returned is relative to the module source directory
ifeq ($(HOST_OS),Windows_NT)
# Always produce list using foward slashes
all-type-files-in-this-a = $(subst \,/,$(subst $(_SDIR),,$(shell cmd.exe /C dir /b $(_SDIR)$(2)$(PATH_SEP)$(1))))
all-type-files-in-this = $(foreach kern,$(call all-type-files-in-this-a,$(1),$(2)),$(2)/$(kern))
else
all-type-files-in-this = $(subst $(SDIR)/,,$(shell find $(SDIR)/$(2) -maxdepth 1 -name '$(1)'))
endif
# This finds files in a specific folder
all-type-files-in = $(notdir $(wildcard $(2)/$(1)))
# This finds all the files within and under a specific folder 
all-type-files-under = $(subst $(SDIR)/,,$(call rwildcard,$(SDIR)/$(1),$(2)))
# This finds all the files within and under a folder of a specific type
all-type-files = $(subst $(SDIR)/,,$(call rwildcard,$(SDIR),$(1)))

all-java-files = $(call all-type-files,*.java)
all-c-files    = $(call all-type-files,*.c)
all-cpp-files  = $(call all-type-files,*.cpp)
all-h-files    = $(call all-type-files,*.h)
all-S-files    = $(call all-type-files,*.S)
all-java-files-in = $(call all-type-files-in,*.java,$(1))
all-c-files-in    = $(call all-type-files-in,*.c,$(1))
all-cpp-files-in  = $(call all-type-files-in,*.cpp,$(1))
all-h-files-in    = $(call all-type-files-in,*.h,$(1))
all-S-files-in    = $(call all-type-files-in,*.S,$(1))
