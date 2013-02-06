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

TARGET_PLATFORM ?= PC

SYSIDIRS := $(HOST_ROOT)/include
SYSLDIRS :=
SYSDEFS  :=

ifeq ($(TARGET_PLATFORM),PC)
    TARGET_OS=$(HOST_OS)
    TARGET_CPU?=$(HOST_CPU)
    ifeq ($(TARGET_OS),LINUX)
        INSTALL_LIB := /usr/lib
        INSTALL_BIN := /usr/bin
        INSTALL_INC := /usr/include
        TARGET_NUM_CORES:=$(shell cat /proc/cpuinfo | grep processor | wc -l)
        SYSIDIRS += /usr/include
        SYSLDIRS += /usr/lib
        SYSDEFS+=_XOPEN_SOURCE=700 _BSD_SOURCE=1 _GNU_SOURCE=1
    else ifeq ($(TARGET_OS),DARWIN)
        INSTALL_LIB := /opt/local/lib
        INSTALL_BIN := /opt/local/bin
        INSTALL_INC := /opt/local/include
        TARGET_NUM_CORES ?= 2
        SYSDEFS += _XOPEN_SOURCE=700 _BSD_SOURCE=1 _GNU_SOURCE=1
    else ifeq ($(TARGET_OS),CYGWIN)
        INSTALL_LIB := /usr/lib
        INSTALL_BIN := /usr/bin
        INSTALL_INC := /usr/include
        TARGET_NUM_CORES ?= 2
        SYSDEFS+=_XOPEN_SOURCE=700 _BSD_SOURCE=1 _GNU_SOURCE=1 WINVER=0x501
    else ifeq ($(TARGET_OS),Windows_NT)
        INSTALL_LIB := "${windir}\\system32"
        INSTALL_BIN := "${windir}\\system32"
        INSTALL_INC :=
        TARGET_NUM_CORES := $(NUMBER_OF_PROCESSORS)
        SYSDEFS+=WIN32_LEAN_AND_MEAN WIN32 _WIN32 _CRT_SECURE_NO_DEPRECATE WINVER=0x0501 _WIN32_WINNT=0x0501
    endif
endif


SYSDEFS += $(TARGET_OS) $(TARGET_CPU) $(TARGET_PLATFORM) TARGET_NUM_CORES=$(TARGET_NUM_CORES)

ifeq ($(TARGET_OS),LINUX)
    PLATFORM_LIBS := dl pthread rt
else ifeq ($(TARGET_OS),DARWIN)
    PLATFORM_LIBS :=
else ifeq ($(TARGET_OS),Windows_NT)
    PLATFORM_LIBS := Ws2_32 user32
else ifeq ($(TARGET_OS),CYGWIN)
    PLATFORM_LIBS := c pthread
endif

ifeq ($(TARGET_CPU),X86)
    TARGET_ARCH=32
else ifeq ($(TARGET_CPU),X64)
    TARGET_ARCH=64
else ifeq ($(TARGET_CPU),x86_64)
    TARGET_ARCH=64
else ifeq ($(TARGET_CPU),ARM)
    TARGET_ARCH=32
else ifeq ($(TARGET_CPU),i386)
    TARGET_ARCH=32
endif

TARGET_ARCH?=32

SYSDEFS+=ARCH_$(TARGET_ARCH)

ifeq ($(BUILD_DEBUG),1)
$(info SYSDEFS = $(SYSDEFS))
$(info SYSIDIRS = $(SYSIDIRS))
$(info SYSLDIRS = $(SYSLDIRS))
endif

