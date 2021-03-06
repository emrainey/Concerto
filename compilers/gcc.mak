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

ifeq ($(TARGET_CPU),$(HOST_CPU))
	CROSS_COMPILE:=
endif

ifeq ($(TARGET_CPU),X86)
	CROSS_COMPILE:=
endif

ifneq ($(HOST_FAMILY),$(TARGET_FAMILY))
$(if $(CROSS_COMPILE),,$(error Cross Compiling is not enabled! TARGET_FAMILY != HOST_FAMILY))
endif

ifeq ($(HOST_OS),Windows_NT)
$(if $(GCC_ROOT),,$(error GCC_ROOT must be defined!))
$(if $(filter $(subst ;,$(SPACE),$(PATH)),$(GCC_ROOT)),,$(error GCC_ROOT must be in PATH as well as secondary directories))
endif

# check for the supported CPU types for this compiler
ifeq ($(filter $(TARGET_FAMILY),ARM X86 x86_64),)
$(error TARGET_FAMILY $(TARGET_FAMILY) is not supported by this compiler)
endif

# check for the support OS types for this compiler
ifeq ($(filter $(TARGET_OS),LINUX CYGWIN DARWIN NO_OS),)
$(error TARGET_OS $(TARGET_OS) is not supported by this compiler)
endif

ifdef GCC_VER
GCC_POSTFIX := -$(GCC_VER)
endif

ifneq ($(GCC_ROOT),)
CC = $(GCC_ROOT)/bin/$(CROSS_COMPILE)gcc$(GCC_POSTFIX)
CP = $(GCC_ROOT)/bin/$(CROSS_COMPILE)g++$(GCC_POSTFIX)
AS = $(GCC_ROOT)/bin/$(CROSS_COMPILE)as
AR = $(GCC_ROOT)/bin/$(CROSS_COMPILE)ar
LD = $(GCC_ROOT)/bin/$(CROSS_COMPILE)g++$(GCC_POSTFIX)
else
# distcc=yes allows for distributed builds
ifeq ($(distcc),yes)
CC = distcc
else
CC = $(CROSS_COMPILE)gcc$(GCC_POSTFIX)
endif
CP = $(CROSS_COMPILE)g++$(GCC_POSTFIX)
AS = $(CROSS_COMPILE)as
AR = $(CROSS_COMPILE)ar
LD = $(CROSS_COMPILE)g++$(GCC_POSTFIX)
endif
EXTS := .c .cc .cpp .cxx .C .CC .CPP .CXX .S .s .asm .ASM

ifeq ($(strip $($(_MODULE)_TYPE)),library)
BIN_PRE:=$(LIB_PRE)
BIN_EXT:=$(LIB_EXT)
else ifeq ($(strip $($(_MODULE)_TYPE)),dsmo)
BIN_PRE:=$(LIB_PRE)
BIN_EXT:=$(DSO_EXT)
else
BIN_PRE:=
BIN_EXT:=$(EXE_EXT)
endif

$(_MODULE)_OUT  := $(BIN_PRE)$($(_MODULE)_TARGET)$(BIN_EXT)
$(_MODULE)_BIN  := $($(_MODULE)_TDIR)/$($(_MODULE)_OUT)
# for each extension types, convert the source file to an object file, remove duplicates and then remove anything that isn't an object
$(_MODULE)_OBJS := $(filter %$(OBJ_EXT), $(sort $(foreach ext,$(EXTS),$($(_MODULE)_SRCS:%$(ext)=$($(_MODULE)_ODIR)/%$(OBJ_EXT)) )))
# Redefine the local static libs and shared libs with REAL paths and pre/post-fixes
$(_MODULE)_STATIC_LIBS := $(foreach lib,$($(_MODULE)_STATIC_LIBS),$($(_MODULE)_TDIR)/$(LIB_PRE)$(lib)$(LIB_EXT))
$(_MODULE)_SHARED_LIBS := $(foreach lib,$($(_MODULE)_SHARED_LIBS),$($(_MODULE)_TDIR)/$(LIB_PRE)$(lib)$(DSO_EXT))
ifeq ($(BUILD_MULTI_PROJECT),1)
$(_MODULE)_STATIC_LIBS += $(foreach lib,$($(_MODULE)_SYS_STATIC_LIBS),$($(_MODULE)_TDIR)/$(LIB_PRE)$(lib)$(LIB_EXT))
$(_MODULE)_SHARED_LIBS += $(foreach lib,$($(_MODULE)_SYS_SHARED_LIBS),$($(_MODULE)_TDIR)/$(LIB_PRE)$(lib)$(DSO_EXT))
$(_MODULE)_PLATFORM_LIBS := $(foreach lib,$(PLATFORM_LIBS),$($(_MODULE)_TDIR)/$(LIB_PRE)$(lib)$(DSO_EXT))
else
$(_MODULE)_PLATFORM_LIBS := $(PLATFORM_LIBS)
endif
$(_MODULE)_DEP_HEADERS := $(foreach inc,$($(_MODULE)_HEADERS),$($(_MODULE)_SDIR)/$(inc).h)

ifneq ($(TARGET_OS),CYGWIN)
$(_MODULE)_COPT += -fPIC
endif
$(_MODULE)_COPT += -Wall -fms-extensions -Wno-write-strings

ifeq ($(TARGET_BUILD),debug)
$(_MODULE)_COPT += -O0 -ggdb3 -gdwarf-2
$(_MODULE)_AFLAGS += --gdwarf-2
else ifeq ($(TARGET_BUILD),release)
$(_MODULE)_COPT += -O3 -ggdb3 -DNDEBUG
else ifeq ($(TARGET_BUILD),production)
$(_MODULE)_COPT += -O3 -DNDEBUG
# Remove all symbols.
$(_MODULE)_LOPT += -s
else ifeq ($(TARGET_BUILD),profiling)
$(_MODULE)_COPT += -pg -O1 -D_GLIBCXX_PROFILE
#$(_MODULE)_LOPT += -pg
endif

ifeq ($(TARGET_FAMILY),ARM)
ifeq ($(TARGET_ENDIAN),LITTLE)
$(_MODULE)_COPT += -mlittle-endian
else
$(_MODULE)_COPT += -mbig-endian
endif
endif

ifeq ($(TARGET_FAMILY),ARM)
$(_MODULE)_COPT += -mapcs -mno-sched-prolog -mno-thumb-interwork -marm
ifeq ($(TARGET_OS),LINUX)
$(_MODULE)_COPT += -mabi=aapcs-linux
endif
endif

ifeq ($(HOST_CPU),$(TARGET_CPU))
$(_MODULE)_COPT += -march=native
ifneq ($(filter $(TARGET_FAMILY),X86 x86_64),)
$(_MODULE)_COPT += -mno-avx
endif
else ifeq ($(TARGET_CPU),M3)
$(_MODULE)_COPT += -mcpu=cortex-m3
else ifeq ($(TARGET_CPU),M4)
$(_MODULE)_COPT += -mcpu=cortex-m4
else ifneq ($(filter $(TARGET_CPU),A8 A8F),)
$(_MODULE)_COPT += -mcpu=cortex-a8
else ifneq ($(filter $(TARGET_CPU),A9 A9F),)
$(_MODULE)_COPT += -mcpu=cortex-a9
else ifneq ($(filter $(TARGET_CPU),A15 A15F),)
$(_MODULE)_COPT += -mcpu=cortex-a15
endif

$(_MODULE)_MAP      := $($(_MODULE)_BIN).map
$(_MODULE)_INCLUDES := $(addprefix -I,$($(_MODULE)_IDIRS))
$(_MODULE)_DEFINES  := $(addprefix -D,$($(_MODULE)_DEFS))
$(_MODULE)_LIBRARIES:= $(addprefix -L,$($(_MODULE)_LDIRS)) \
					   $(addprefix -l,$(STATIC_LIBS) $(SYS_STATIC_LIBS) \
									  $(SHARED_LIBS) $(SYS_SHARED_LIBS) $(PLATFORM_LIBS))
$(_MODULE)_SYMBOLS	:= $(foreach sym,$($(_MODULE)_DEFS),$(if $(word 2,$(subst =,$(SPACE),$(sym))), --defsym $(sym),--defsym $(sym)=1))
$(_MODULE)_AFLAGS   += $($(_MODULE)_INCLUDES) $($(_MODULE)_SYMBOLS)
ifeq ($(HOST_OS),DARWIN)
$(_MODULE)_LDFLAGS  := -arch $(TARGET_CPU) $(LDFLAGS)
endif
$(_MODULE)_LDFLAGS  += $($(_MODULE)_LOPT)
$(_MODULE)_CPLDFLAGS := $(foreach ldf,$($(_MODULE)_LDFLAGS),-Wl,$(ldf)) $($(_MODULE)_COPT)
$(_MODULE)_CFLAGS   := -c $($(_MODULE)_INCLUDES) $($(_MODULE)_DEFINES) $($(_MODULE)_COPT) $(CFLAGS)

###################################################
# COMMANDS
###################################################
ifneq ($(TARGET_OS),CYGWIN)
EXPORT_FLAG:=--export-dynamic
EXPORTER   :=-rdynamic
else
EXPORT_FLAG:=--export-all-symbols
EXPORTER   :=
endif

$(_MODULE)_LINK_LIB   = $(AR) -rscu $($(_MODULE)_BIN) $($(_MODULE)_OBJS)
ifeq ($(HOST_OS),DARWIN)
$(_MODULE)_LINK_DSO   = $(LD) -shared $($(_MODULE)_LDFLAGS) -all_load $($(_MODULE)_LIBRARIES) -lm -o $($(_MODULE)_BIN).$($(_MODULE)_VERSION) $($(_MODULE)_OBJS)
$(_MODULE)_LINK_EXE   = $(LD) -rdynamic $($(_MODULE)_CPLDFLAGS) $($(_MODULE)_OBJS) $($(_MODULE)_LIBRARIES) $(addprefix -l,$1) -o $($(_MODULE)_BIN)
else
$(_MODULE)_LINK_DSO   = $(LD) $($(_MODULE)_LDFLAGS) -shared -Wl,$(EXPORT_FLAG) -Wl,-soname,$(notdir $($(_MODULE)_BIN)).$($(_MODULE)_VERSION) $($(_MODULE)_OBJS) -Wl,--whole-archive $($(_MODULE)_LIBRARIES) -lm -Wl,--no-whole-archive -o $($(_MODULE)_BIN).$($(_MODULE)_VERSION) -Wl,-Map=$($(_MODULE)_MAP)
$(_MODULE)_LINK_EXE   = $(LD) $(EXPORTER) -Wl,--cref $($(_MODULE)_CPLDFLAGS) $($(_MODULE)_OBJS) $($(_MODULE)_LIBRARIES) $(addprefix -l,$1) -o $($(_MODULE)_BIN) -Wl,-Map=$($(_MODULE)_MAP)
endif

###################################################
# MACROS FOR COMPILING
###################################################

define $(_MODULE)_BUILD
build:: $($(_MODULE)_BIN)
endef

ifeq ($(HOST_OS),Windows_NT)

ifeq ($(MAKE_VERSION),3.80)
$(_MODULE)_GCC_DEPS = -MMD -MF $(ODIR)/$(1).dep -MT '$(ODIR)/$(1)$(OBJ_EXT)'
$(_MODULE)_ASM_DEPS = -MD $(ODIR)/$(1).dep
endif

define $(_MODULE)_COMPILE_TOOLS
$(ODIR)/%$(OBJ_EXT): $(SDIR)/%.c $($(_MODULE)_DEP_HEADERS) $(SDIR)/$(SUBMAKEFILE)
	@echo [GCC] Compiling C99 $$(notdir $$<)
	$(Q)$(CC) -std=c99 $($(_MODULE)_CFLAGS) $(call $(_MODULE)_GCC_DEPS,$$*) $$< -o $$@ $(LOGGING)

$(ODIR)/%$(OBJ_EXT): $(SDIR)/%.cpp $($(_MODULE)_DEP_HEADERS) $(SDIR)/$(SUBMAKEFILE)
	@echo [GCC] Compiling C++11 $$(notdir $$<)
	$(Q)$(CP) -std=c++11 $($(_MODULE)_CFLAGS) $(call $(_MODULE)_GCC_DEPS,$$*) $$< -o $$@ $(LOGGING)

$(ODIR)/%$(OBJ_EXT): $(SDIR)/%.cc $($(_MODULE)_DEP_HEADERS) $(SDIR)/$(SUBMAKEFILE)
	@echo [GCC] Compiling C++11 $$(notdir $$<)
	$(Q)$(CP) -std=c++11 $($(_MODULE)_CFLAGS) $(call $(_MODULE)_GCC_DEPS,$$*) $$< -o $$@ $(LOGGING)

$(ODIR)/%$(OBJ_EXT): $(SDIR)/%.S $(SDIR)/$(SUBMAKEFILE)
	@echo [GCC] Assembling $$(notdir $$<)
	$(Q)$(AS) $($(_MODULE)_AFLAGS) $(call $(_MODULE)_ASM_DEPS,$$*) $$< -o $$@ $(LOGGING)
endef

else

define $(_MODULE)_COMPILE_TOOLS
$(ODIR)/%$(OBJ_EXT): $(SDIR)/%.c $($(_MODULE)_DEP_HEADERS) $(SDIR)/$(SUBMAKEFILE)
	@echo [GCC] Compiling C99 $$(notdir $$<)
	$(Q)$(CC) -std=c99 $($(_MODULE)_CFLAGS) -MMD -MF $(ODIR)/$$*.dep -MT '$(ODIR)/$$*$(OBJ_EXT)' $$< -o $$@ $(LOGGING)

$(ODIR)/%$(OBJ_EXT): $(SDIR)/%.cpp $($(_MODULE)_DEP_HEADERS) $(SDIR)/$(SUBMAKEFILE)
	@echo [GCC] Compiling C++11 $$(notdir $$<)
	$(Q)$(CP) -std=c++11 $($(_MODULE)_CFLAGS) -MMD -MF $(ODIR)/$$*.dep -MT '$(ODIR)/$$*$(OBJ_EXT)' $$< -o $$@ $(LOGGING)

$(ODIR)/%$(OBJ_EXT): $(SDIR)/%.cc $($(_MODULE)_DEP_HEADERS) $(SDIR)/$(SUBMAKEFILE)
	@echo [GCC] Compiling C++11 $$(notdir $$<)
	$(Q)$(CP) -std=c++11 $($(_MODULE)_CFLAGS) -MMD -MF $(ODIR)/$$*.dep -MT '$(ODIR)/$$*$(OBJ_EXT)' $$< -o $$@ $(LOGGING)

$(ODIR)/%$(OBJ_EXT): $(SDIR)/%.S $(SDIR)/$(SUBMAKEFILE)
	@echo [GCC] Assembling $$(notdir $$<)
	$(Q)$(AS) $($(_MODULE)_AFLAGS) -MD $(ODIR)/$$*.dep $$< -o $$@ $(LOGGING)
endef

endif
