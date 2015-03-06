# Copyright (C) 2011 Erik Rainey
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

ifeq ($(TARGET_FAMILY),$(HOST_FAMILY))
	CROSS_COMPILE:=
endif

# check for the supported CPU types for this compiler
ifeq ($(filter $(TARGET_FAMILY),X86 x86_64 ARM),)
$(error TARGET_FAMILY $(TARGET_FAMILY) is not supported by this compiler)
endif

# check for the support OS types for this compiler
ifeq ($(filter $(TARGET_OS),LINUX CYGWIN DARWIN),)
$(error TARGET_OS $(TARGET_OS) is not supported by this compiler)
endif

CC = $(CROSS_COMPILE)clang
CP = $(CROSS_COMPILE)clang++
AS = $(CROSS_COMPILE)as
AR = $(CROSS_COMPILE)ar
LD = $(CROSS_COMPILE)clang++

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
$(_MODULE)_OBJS := $(ASSEMBLY:%.S=$($(_MODULE)_ODIR)/%$(OBJ_EXT)) $(CPPSOURCES:%.cpp=$($(_MODULE)_ODIR)/%$(OBJ_EXT)) $(CSOURCES:%.c=$($(_MODULE)_ODIR)/%$(OBJ_EXT))
# Redefine the local static libs and shared libs with REAL paths and pre/post-fixes
$(_MODULE)_STATIC_LIBS := $(foreach lib,$(STATIC_LIBS),$($(_MODULE)_TDIR)/$(LIB_PRE)$(lib)$(LIB_EXT))
$(_MODULE)_SHARED_LIBS := $(foreach lib,$(SHARED_LIBS),$($(_MODULE)_TDIR)/$(LIB_PRE)$(lib)$(DSO_EXT))
ifeq ($(BUILD_MULTI_PROJECT),1)
$(_MODULE)_STATIC_LIBS += $(foreach lib,$(SYS_STATIC_LIBS),$($(_MODULE)_TDIR)/$(LIB_PRE)$(lib)$(LIB_EXT))
$(_MODULE)_SHARED_LIBS += $(foreach lib,$(SYS_SHARED_LIBS),$($(_MODULE)_TDIR)/$(LIB_PRE)$(lib)$(DSO_EXT))
$(_MODULE)_PLATFORM_LIBS := $(foreach lib,$(PLATFORM_LIBS),$($(_MODULE)_TDIR)/$(LIB_PRE)$(lib)$(DSO_EXT))
else
$(_MODULE)_PLATFORM_LIBS := $(PLATFORM_LIBS)
endif
$(_MODULE)_DEP_HEADERS := $(foreach inc,$($(_MODULE)_HEADERS),$($(_MODULE)_SDIR)/$(inc).h)

# We need these to do things like OpenCL/GL/etc.
$(_MODULE)_COPT := $(CFLAGS)
$(_MODULE)_LOPT := $(LDFLAGS)
ifneq ($(TARGET_OS),CYGWIN)
$(_MODULE)_COPT += -fPIC
endif
$(_MODULE)_COPT += -Weverything -Wno-deprecated -Wno-c++98-compat -Wno-c++98-compat-pedantic \
                   -fcolor-diagnostics -Wno-disabled-macro-expansion -Wno-padded

ifeq ($(TARGET_BUILD),debug)
$(_MODULE)_COPT += -O0 -ggdb3 -gdwarf-2
$(_MODULE)_AFLAGS := --gdwarf-2
else ifeq ($(TARGET_BUILD),release)
$(_MODULE)_COPT += -O3 -ggdb3
else ifeq ($(TARGET_BUILD),production)
$(_MODULE)_COPT += -O3
# Remove all symbols.
$(_MODULE)_LOPT += -s
else ifeq ($(TARGET_BUILD),profiling)
$(_MODULE)_COPT += -pg -O1
#$(_MODULE)_LOPT += -pg
endif

# This doesn't appear to do anything with CLANG (shouldn't it?)
ifeq ($(TARGET_FAMILY),ARM)
#$(_MODULE)_COPT += -arch arm
endif

ifneq ($(TARGET_FAMILY),ARM)
$(_MODULE)_COPT += -m$(TARGET_ARCH)
endif

$(_MODULE)_MAP      := $($(_MODULE)_BIN).map
$(_MODULE)_INCLUDES := $(foreach inc,$($(_MODULE)_IDIRS),-I$(inc))
$(_MODULE)_DEFINES  := $(foreach def,$($(_MODULE)_DEFS),-D$(def))
$(_MODULE)_LIBRARIES:= $(foreach ldir,$($(_MODULE)_LDIRS),-L$(ldir)) \
					   $(foreach lib,$(STATIC_LIBS),-l$(lib)) \
					   $(foreach lib,$(SYS_STATIC_LIBS),-l$(lib)) \
					   $(foreach lib,$(SHARED_LIBS),-l$(lib)) \
					   $(foreach lib,$(SYS_SHARED_LIBS),-l$(lib)) \
					   $(foreach lib,$(PLATFORM_LIBS),-l$(lib))
$(_MODULE)_AFLAGS   += $($(_MODULE)_INCLUDES)
ifeq ($(HOST_OS),DARWIN)
$(_MODULE)_LDFLAGS  := -arch $(TARGET_CPU)
endif
$(_MODULE)_LDFLAGS  += $($(_MODULE)_LOPT)
$(_MODULE)_CPLDFLAGS := $(foreach ldf,$($(_MODULE)_LDFLAGS),-Wl,$(ldf)) $($(_MODULE)_FRAMEWORKS) $($(_MODULE)_COPT)
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

$(_MODULE)_LN_DSO     := $(LINK) $($(_MODULE)_BIN).$($(_MODULE)_VERSION) $($(_MODULE)_BIN)
$(_MODULE)_LN_INST_DSO:= $(LINK) $($(_MODULE)_INSTALL_LIB)/$($(_MODULE)_OUT).$($(_MODULE)_VERSION) $($(_MODULE)_INSTALL_LIB)/$($(_MODULE)_OUT)
$(_MODULE)_LINK_LIB   := $(AR) -rscu $($(_MODULE)_BIN) $($(_MODULE)_OBJS) #$($(_MODULE)_STATIC_LIBS)
ifeq ($(TARGET_OS),DARWIN)
$(_MODULE)_LINK_DSO   := $(LD) -dynamiclib $($(_MODULE)_LDFLAGS) -all_load $($(_MODULE)_LIBRARIES) -lm -o $($(_MODULE)_BIN).$($(_MODULE)_VERSION) $($(_MODULE)_OBJS)
$(_MODULE)_LINK_EXE   := $(LD) $($(_MODULE)_CPLDFLAGS) $($(_MODULE)_OBJS) $($(_MODULE)_LIBRARIES) -o $($(_MODULE)_BIN)
else
$(_MODULE)_LINK_DSO   := $(LD) $($(_MODULE)_LDFLAGS) -shared -Wl,$(EXPORT_FLAG) -Wl,-soname,$(notdir $($(_MODULE)_BIN)).$($(_MODULE)_VERSION) $($(_MODULE)_OBJS) -Wl,--whole-archive $($(_MODULE)_LIBRARIES) -lm -Wl,--no-whole-archive -o $($(_MODULE)_BIN).$($(_MODULE)_VERSION)
$(_MODULE)_LINK_EXE   := $(LD) $(EXPORTER) -Wl,--cref $($(_MODULE)_CPLDFLAGS) $($(_MODULE)_OBJS) $($(_MODULE)_LIBRARIES) -o $($(_MODULE)_BIN) -Wl,-Map=$($(_MODULE)_MAP)
endif

###################################################
# MACROS FOR COMPILING
###################################################

define $(_MODULE)_BUILD
build:: $($(_MODULE)_BIN)
endef

define $(_MODULE)_ANALYZER

analysis::$(CPPSOURCES:%.cpp=$(ODIR)/%.xml) $(CSOURCES:%.c=$(ODIR)/%.xml)

$(ODIR)/%.xml: $(SDIR)/%.c $(ODIR)/.gitignore $(SDIR)/$(SUBMAKEFILE)
	@echo [CLANG] Analyzing C $$(notdir $$<)
	$(Q)$(CC) --analyze $($(_MODULE)_CFLAGS) $$< -o $$@

$(ODIR)/%.xml: $(SDIR)/%.cpp $(ODIR)/.gitignore $(SDIR)/$(SUBMAKEFILE)
	@echo [CLANG++] Analyzing C++ $$(notdir $$<)
	$(Q)$(CP) --analyze $($(_MODULE)_CFLAGS) $$< -o $$@
endef

define $(_MODULE)_COMPILE_TOOLS
$(ODIR)/%$(OBJ_EXT): $(SDIR)/%.c $($(_MODULE)_DEP_HEADERS) $(SDIR)/$(SUBMAKEFILE)
	@echo [CLANG] Compiling C99 $$(notdir $$<)
	$(Q)$(CC) -std=c99 $($(_MODULE)_CFLAGS) -MMD -MF $(ODIR)/$$*.dep -MT '$(ODIR)/$$*$(OBJ_EXT)' $$< -o $$@ $(LOGGING)

$(ODIR)/%$(OBJ_EXT): $(SDIR)/%.cpp $($(_MODULE)_DEP_HEADERS) $(SDIR)/$(SUBMAKEFILE)
	@echo [CLANG++] Compiling C++11 $$(notdir $$<)
	$(Q)$(CP) -std=c++11 $($(_MODULE)_CFLAGS) -MMD -MF $(ODIR)/$$*.dep -MT '$(ODIR)/$$*$(OBJ_EXT)' $$< -o $$@ $(LOGGING)

$(ODIR)/%$(OBJ_EXT): $(SDIR)/%.S $(SDIR)/$(SUBMAKEFILE)
	@echo [CLANG] Assembling $$(notdir $$<)
	$(Q)$(AS) $($(_MODULE)_AFLAGS) -MD $(ODIR)/$$*.dep $$< -o $$@ $(LOGGING)
endef
