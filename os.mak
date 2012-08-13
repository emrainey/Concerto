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
        HOST_COMPILER=GCC
    else ifeq ($(TERM),xterm)
        HOST_OS=CYGWIN
        HOST_COMPILER=GCC
        P2W_CONV=$(patsubst \cygdrive\c\%,c:\%,$(subst /,\,$(1)))
        W2P_CONV=$(subst \,/,$(patsubst C:\%,\cygdrive\c\% $(1)))
    else
        HOST_OS=Windows_NT
        HOST_COMPILER=CL
        CL_ROOT?=$(VCINSTALLDIR)
    endif
else
    OS=$(shell uname -s)
    ifeq ($(OS),Linux)
        HOST_OS=LINUX
        HOST_COMPILER?=GCC
    else ifeq ($(OS),Darwin)
        HOST_OS=DARWIN
        HOST_COMPILER=GCC
    else ifeq ($(OS),CYGWIN_NT-5.1)
        HOST_OS=CYGWIN
        HOST_COMPILER=GCC
        P2W_CONV=$(patsubst \cygdrive\c\%,c:\%,$(subst /,\,$(1)))
        W2P_CONV=$(subst \,/,$(patsubst C:\%,\cygdrive\c\% $(1)))
    else
        HOST_OS=POSIX
        HOST_COMPILER=GCC
    endif
endif

ifeq ($(HOST_OS),Windows_NT)
    PATH_CONV=$(subst /,\,$(1))
else
    PATH_CONV=$(subst _,_,$(1))
endif

$(info HOST_OS=$(HOST_OS))
$(info HOST_COMPILER=$(HOST_COMPILER))

