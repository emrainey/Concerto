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

ifeq ($(OS),Windows_NT)
    ifeq ($(TERM),cygwin)
        HOST_OS=CYGWIN
        HOST_NUM_CORES := $(shell cat /proc/cpuinfo | grep processor | wc -l)
    else ifeq ($(TERM),xterm)
        HOST_OS=CYGWIN
        P2W_CONV=$(patsubst \cygdrive\c\%,c:\%,$(subst /,\,$(1)))
        W2P_CONV=$(subst \,/,$(patsubst C:\%,\cygdrive\c\% $(1)))
        HOST_NUM_CORES := $(shell cat /proc/cpuinfo | grep processor | wc -l)
    else
        HOST_OS=Windows_NT
        CL_ROOT?=$(VCINSTALLDIR)
        HOST_NUM_CORES := $(NUM_PROCESSORS)
    endif
else
    OS=$(shell uname -s)
    ifeq ($(OS),Linux)
        HOST_OS=LINUX
        HOST_NUM_CORES := $(shell cat /proc/cpuinfo | grep processor | wc -l)
    else ifeq ($(OS),Darwin)
        HOST_OS=DARWIN
        HOST_NUM_CORES := $(word 2,$(shell sysctl hw.ncpu))
    else ifeq ($(OS),CYGWIN_NT-5.1)
        HOST_OS=CYGWIN
        P2W_CONV=$(patsubst \cygdrive\c\%,c:\%,$(subst /,\,$(1)))
        W2P_CONV=$(subst \,/,$(patsubst C:\%,\cygdrive\c\% $(1)))
        HOST_NUM_CORES := $(shell cat /proc/cpuinfo | grep processor | wc -l)
    else
        HOST_OS=POSIX
    endif
endif

# PATH_CONV and set HOST_COMPILER if not yet specified
ifeq ($(HOST_OS),Windows_NT)
    STRING_ESCAPE=$(subst \,\\,$(1))
    PATH_CONV=$(subst /,\,$(1))
    PATH_SEP=\\
    PATH_SEPD=$(strip \)
    PATH_CAT=;
    HOST_COMPILER?=CL
else
    STRING_ESCAPE=$(1)
    PATH_CONV=$(1)
    PATH_SEP=/
    PATH_SEPD=/
    PATH_CAT=:
    HOST_COMPILER?=GCC
endif

ifeq ($(HOST_OS),Windows_NT)
$(info ComSpec=$(ComSpec))
    SHELL:=$(ComSpec)
    .SHELLFLAGS=/C
else
    SHELL:=/bin/sh
endif

PATH_CONCAT = $(subst $(SPACE),$(PATH_CAT),$(1))
GAP:='%20'
FIND-IN-PATH = $(sort $(foreach path,$(subst $(PATH_CAT),$(SPACE),$(subst $(SPACE),$(GAP),$(PATH))),$(wildcard $(path)$(PATH_DELIM)$(1))))

ifeq ($(SHOW_MAKEDEBUG),1)
$(info SHELL=$(SHELL))
endif
