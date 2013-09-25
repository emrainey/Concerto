# Copyright (C) 2013 Erik Rainey
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

# Any OS can build itself and maybe some secondary OS's

ifeq ($(HOST_PLATFORM),PC)
ifneq ($(HOST_CPU),ARM)
# PANDA ARM is self-hosting
TARGET_COMBOS := $(call FILTER_OUT_COMBO,PANDA)
endif
ifeq ($(HOST_FAMILY),X86)
TARGET_COMBOS := $(call FILTER_OUT_COMBO,x86_64)
endif
ifeq ($(HOST_OS),LINUX)
TARGET_COMBOS := $(call FILTER_COMBO,LINUX SYSBIOS __QNX__ NO_OS)
else ifneq ($(filter $(HOST_OS),CYGWIN DARWIN),)
TARGET_COMBOS := $(call FILTER_COMBO,$(HOST_OS))
else ifeq ($(HOST_OS),Windows_NT)
TARGET_COMBOS := $(call FILTER_COMBO,$(HOST_OS) SYSBIOS NO_OS)
endif
else ifeq ($(HOST_PLATFORM),PANDA)
TARGET_COMBOS := $(call FILTER_COMBO,$(HOST_PLATFORM))
endif

# If the platform is set, remove others which are not on that platform.
ifneq ($(TARGET_PLATFORM),)
#$(info Want $(TARGET_PLATFORM) in $(TARGET_COMBOS))
TARGET_COMBOS := $(call FILTER_COMBO,$(TARGET_PLATFORM))
endif

# If the OS is set, remove others which are not on that OS.
ifneq ($(TARGET_OS),)
#$(info Want $(TARGET_OS) in $(TARGET_COMBOS))
TARGET_COMBOS := $(call FILTER_COMBO,$(TARGET_OS))
endif

# If the CPU is set, remove others which are not on that CPU.
ifneq ($(TARGET_CPU),)
#$(info Want $(TARGET_CPU) in $(TARGET_COMBOS))
TARGET_COMBOS := $(call FILTER_COMBO,$(TARGET_CPU))
endif

# The compilers which must have roots set. 
COMPILER_ROOTS := TIARMCGT_ROOT TMS470_ROOT ARP32CGT_ROOT CGT6X_ROOT CGT7X_ROOT

# The compiler which do not have roots set.
REMOVE_ROOTS := $(foreach root,$(COMPILER_ROOTS),$(if $(filter $(origin $(root)),undefined),$(root)))

# The list of targets which can not be built
TARGET_COMBOS := $(call FILTER_OUT_COMBO,$(foreach root,$(REMOVE_ROOTS),$(subst _ROOT,,$(root))))

#ifeq ($(BUILD_DEBUG),1)
$(info Remaining COMBOS = $(TARGET_COMBOS))
#endif

