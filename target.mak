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

ifndef TARGET_PLATFORM
	TARGET_PLATFORM=PC
endif

ifeq ($(TARGET_PLATFORM),PC)
	TARGET_OS=$(HOST_OS)
	TARGET_CPU=$(HOST_CPU)
	INSTALL_LIB := /usr/lib/
	INSTALL_BIN := /usr/bin/
	INSTALL_INC := /usr/include/
	ifeq ($(TARGET_OS),LINUX)
		TARGET_NUM_CORES:=$(shell cat /proc/cpuinfo | grep processor | wc -l)
		SYSIDIRS=/usr/include
		SYSLDIRS=/usr/lib
		SYSDEFS+=_XOPEN_SOURCE=700 _BSD_SOURCE=1 _GNU_SOURCE=1
	else ifeq ($(TARGET_OS),CYGWIN)
		TARGET_NUM_CORES=1
		SYSDEFS+=_XOPEN_SOURCE=700 _BSD_SOURCE=1 _GNU_SOURCE=1 WINVER=0x501
	else ifeq ($(TARGET_OS),Windows_NT)
		TARGET_NUM_CORES := $(NUMBER_OF_PROCESSORS)
		SYSDEFS+=WIN32_LEAN_AND_MEAN WIN32 _WIN32 _CRT_SECURE_NO_DEPRECATE WINVER=0x0501 _WIN32_WINNT=0x0501
	endif
else
endif


SYSDEFS += $(TARGET_OS) $(TARGET_CPU) $(TARGET_PLATFORM) TARGET_NUM_CORES=$(TARGET_NUM_CORES)

ifeq ($(TARGET_CPU),X86)
	TARGET_ARCH=32
else ifeq ($(TARGET_CPU),X64)
	TARGET_ARCH=64
else ifeq ($(TARGET_CPU),x86_64)
	TARGET_ARCH=64
else ifeq ($(TARGET_CPU),ARM)
	TARGET_ARCH=32
	CFLAGS+=-mapcs -mno-sched-prolog -mabi=aapcs-linux -mno-thumb-interwork
endif

ifndef TARGET_ARCH
TARGET_ARCH=32
endif

SYSDEFS+=ARCH_$(TARGET_ARCH)

$(info TARGET_OS=$(TARGET_OS))
$(info TARGET_CPU=$(TARGET_CPU))
$(info TARGET_PLATFORM=$(TARGET_PLATFORM))

