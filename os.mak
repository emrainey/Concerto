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
    else ifeq ($(TERM),xterm)
        HOST_OS=CYGWIN
        P2W_CONV=$(patsubst \cygdrive\c\%,c:\%,$(subst /,\,$(1)))
        W2P_CONV=$(subst \,/,$(patsubst C:\%,\cygdrive\c\% $(1)))
    else
        HOST_OS=Windows_NT
        CL_ROOT?=$(VCINSTALLDIR)
    endif
else
    OS=$(shell uname -s)
    ifeq ($(OS),Linux)
        HOST_OS=LINUX
    else ifeq ($(OS),Darwin)
        HOST_OS=DARWIN
    else ifeq ($(OS),CYGWIN_NT-5.1)
        HOST_OS=CYGWIN
        P2W_CONV=$(patsubst \cygdrive\c\%,c:\%,$(subst /,\,$(1)))
        W2P_CONV=$(subst \,/,$(patsubst C:\%,\cygdrive\c\% $(1)))
    else
        HOST_OS=POSIX
    endif
endif

# TI compilers are only supported on Windows and Linux
ifeq ($(HOST_OS),$(filter $(HOST_OS),Windows_NT LINUX))
    ifneq ($(TARGET_CPU),)
        ifeq ($(TARGET_CPU),$(filter $(TARGET_CPU),C64T C64P C64 C66 C674 C67 C67P))
            HOST_COMPILER?=CGT6X
        else ifeq ($(TARGET_CPU),EVE)
            HOST_COMPILER?=ARP32
        endif
    endif
endif

# PATH_CONV and set HOST_COMPILER if not yet specified
ifeq ($(HOST_OS),Windows_NT)
    PATH_CONV=$(subst /,\,$(1))
    HOST_COMPILER?=CL
else
    PATH_CONV=$(1)
    HOST_COMPILER?=GCC
endif

