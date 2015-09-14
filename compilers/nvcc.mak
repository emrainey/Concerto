# Copyright (C) 2010 Erik Rainey
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#	  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ifeq ($(HAS_CUDA),true)
 
# If SM is not set, use 20
ifeq ($(SM),)
SM := 20
endif

ifeq ($(TARGET_CPU),$(HOST_CPU))
	CROSS_COMPILE:=
endif

ifeq ($(TARGET_CPU),X86)
	CROSS_COMPILE:=
endif

ifneq ($(HOST_FAMILY),$(TARGET_FAMILY))
$(if $(CROSS_COMPILE),,$(error Cross Compiling is not enabled! TARGET_FAMILY != HOST_FAMILY))
endif

# check for the supported CPU types for this compiler
ifeq ($(filter $(TARGET_FAMILY),ARM X86 x86_64),)
$(error TARGET_FAMILY $(TARGET_FAMILY) is not supported by this compiler)
endif

# check for the support OS types for this compiler
ifeq ($(filter $(TARGET_OS),LINUX),)
$(error TARGET_OS $(TARGET_OS) is not supported by this compiler)
endif

NVCC = $(CUDA_ROOT)/bin/nvcc
EXTS := .c .cc .cpp .cxx .C .CC .CPP .CXX .gpu .GPU .ptx .PTX .cu .CU 

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
$(_MODULE)_STATIC_LIBS := $(foreach lib,$(STATIC_LIBS),$($(_MODULE)_TDIR)/lib$(lib)$(LIB_EXT))
$(_MODULE)_SHARED_LIBS := $(foreach lib,$(SHARED_LIBS),$($(_MODULE)_TDIR)/lib$(lib)$(DSO_EXT))
ifeq ($(BUILD_MULTI_PROJECT),1)
$(_MODULE)_STATIC_LIBS += $(foreach lib,$(SYS_STATIC_LIBS),$($(_MODULE)_TDIR)/lib$(lib)$(LIB_EXT))
$(_MODULE)_SHARED_LIBS += $(foreach lib,$(SYS_SHARED_LIBS),$($(_MODULE)_TDIR)/lib$(lib)$(DSO_EXT))
$(_MODULE)_PLATFORM_LIBS := $(foreach lib,$(PLATFORM_LIBS),$($(_MODULE)_TDIR)/lib$(lib)$(DSO_EXT))
else
$(_MODULE)_PLATFORM_LIBS := $(PLATFORM_LIBS)
endif
$(_MODULE)_DEP_HEADERS := $(foreach inc,$($(_MODULE)_HEADERS),$($(_MODULE)_SDIR)/$(inc).h)

$(_MODULE)_SM := $(SM)
# Opts will be pass down through appended flags, flags will not be altered
$(_MODULE)_COPT := -fPIC -Wall
$(_MODULE)_CFLAGS := -arch=sm_$($(_MODULE)_SM)
$(_MODULE)_LOPT :=
$(_MODULE)_LDFLAGS := -arch=sm_$($(_MODULE)_SM)
$(_MODULE)_AFLAGS :=

ifeq ($(TARGET_BUILD),debug)
$(_MODULE)_CFLAGS += -O0 -g -G
else ifeq ($(TARGET_BUILD),release)
$(_MODULE)_CFLAGS += -O3 -g
else ifeq ($(TARGET_BUILD),production)
$(_MODULE)_CFLAGS += -O3
else ifeq ($(TARGET_BUILD),profiling)
$(_MODULE)_CFLAGS += -pg -O1
$(_MODULE)_LDFLAGS += -pg
endif

$(_MODULE)_INCLUDES := $(foreach inc,$($(_MODULE)_IDIRS),-I$(inc))
$(_MODULE)_DEFINES  := $(foreach def,$($(_MODULE)_DEFS),-D$(def))
$(_MODULE)_LIBRARIES:= $(foreach ldir,$($(_MODULE)_LDIRS),-L$(ldir)) \
					   $(foreach lib,$(STATIC_LIBS),-l$(lib)) \
					   $(foreach lib,$(SYS_STATIC_LIBS),-l$(lib)) \
					   $(foreach lib,$(SHARED_LIBS),-l$(lib)) \
					   $(foreach lib,$(SYS_SHARED_LIBS),-l$(lib)) \
					   $(foreach lib,$(PLATFORM_LIBS),-l$(lib))
$(_MODULE)_AFLAGS   += $($(_MODULE)_INCLUDES)
$(_MODULE)_LINKER_OPT :=$(strip $($(_MODULE)_LOPT) $(LDFLAGS))
$(_MODULE)_LDFLAGS  += $(if $($(_MODULE)_LINKER_OPT),-Xlinker=$(subst $(SPACE),$(COMMA),$($(_MODULE)_LINKER_OPT)))
$(_MODULE)_COMPILER_OPT :=$(strip $($(_MODULE)_COPT) $(CFLAGS))
$(_MODULE)_CFLAGS += $($(_MODULE)_INCLUDES) $($(_MODULE)_DEFINES) 
ifeq ($(TARGET_FAMILY),ARM)
$(_MODULE)_CFLAGS += --target-cpu-architecture=ARM
else ifeq ($(TARGET_FAMILY),X86)
$(_MODULE)_CFLAGS += --target-cpu-architecture=X86
endif
ifeq ($(TARGET_OS),LINUX)
$(_MODULE)_CFLAGS += --target-os-variant=Linux
endif
$(_MODULE)_CFLAGS += $(if $($(_MODULE)_COMPILER_OPT),-Xcompiler=$(subst $(SPACE),$(COMMA),$($(_MODULE)_COMPILER_OPT))) $(CUFLAGS)

###################################################
# COMMANDS
###################################################

$(_MODULE)_LINK_LIB   := $(NVCC) --lib $($(_MODULE)_LDFLAGS) $($(_MODULE)_OBJS) -o $($(_MODULE)_BIN) 
$(_MODULE)_LINK_DSO   := $(NVCC) --shared $($(_MODULE)_LDFLAGS) \
	-Xlinker=-soname,$(notdir $($(_MODULE)_BIN)).$($(_MODULE)_VERSION) $($(_MODULE)_OBJS) \
	-Xlinker=--whole-archive $($(_MODULE)_LIBRARIES) -lm -Xlinker=--no-whole-archive \
	-o $($(_MODULE)_BIN).$($(_MODULE)_VERSION) 
	
$(_MODULE)_LINK_EXE   := $(NVCC) $($(_MODULE)_LDFLAGS) $($(_MODULE)_OBJS) $($(_MODULE)_LIBRARIES) -o $($(_MODULE)_BIN) 

###################################################
# MACROS FOR COMPILING
###################################################

define $(_MODULE)_BUILD
build:: $($(_MODULE)_BIN)
endef

define $(_MODULE)_COMPILE_TOOLS
$(ODIR)/%.dep: $(SDIR)/%.c $(SDIR)/$(SUBMAKEFILE) $(ODIR)/.gitignore
	@echo [NVCC] Dependencies for $$(notdir $$<)
	$(Q)$(NVCC) --generate-dependencies $($(_MODULE)_INCLUDES) $$< > $$@

$(ODIR)/%.dep: $(SDIR)/%.cu $(SDIR)/$(SUBMAKEFILE) $(ODIR)/.gitignore
	@echo [NVCC] Dependencies for $$(notdir $$<)
	$(Q)$(NVCC) --generate-dependencies $($(_MODULE)_INCLUDES) $$< > $$@

$(ODIR)/%.dep: $(SDIR)/%.cpp $(SDIR)/$(SUBMAKEFILE) $(ODIR)/.gitignore
	@echo [NVCC] Dependencies for $$(notdir $$<)
	$(Q)$(NVCC) --generate-dependencies $($(_MODULE)_INCLUDES) $$< > $$@

$(ODIR)/%.dep: $(SDIR)/%.cc $(SDIR)/$(SUBMAKEFILE) $(ODIR)/.gitignore
	@echo [NVCC] Dependencies for $$(notdir $$<)
	$(Q)$(NVCC) --generate-dependencies $($(_MODULE)_INCLUDES) $$< > $$@

$(ODIR)/%$(OBJ_EXT): $(SDIR)/%.c $(ODIR)/%.dep $($(_MODULE)_DEP_HEADERS) $(SDIR)/$(SUBMAKEFILE)
	@echo [NVCC] Compiling C99 $$(notdir $$<)
	$(Q)$(NVCC) --std=c99 -dc $($(_MODULE)_CFLAGS) $$< -o $$@ $(LOGGING)

$(ODIR)/%$(OBJ_EXT): $(SDIR)/%.cu $(ODIR)/%.dep $($(_MODULE)_DEP_HEADERS) $(SDIR)/$(SUBMAKEFILE)
	@echo [NVCC] Compiling CU $$(notdir $$<)
	$(Q)$(NVCC) --std=c++11 -dc $($(_MODULE)_CFLAGS) $$< -o $$@ $(LOGGING)

$(ODIR)/%$(OBJ_EXT): $(SDIR)/%.cpp $(ODIR)/%.dep $($(_MODULE)_DEP_HEADERS) $(SDIR)/$(SUBMAKEFILE)
	@echo [NVCC] Compiling C++ $$(notdir $$<)
	$(Q)$(NVCC) --std=c++11 -dc $($(_MODULE)_CFLAGS) $$< -o $$@ $(LOGGING)

$(ODIR)/%$(OBJ_EXT): $(SDIR)/%.cc $(ODIR)/%.dep $($(_MODULE)_DEP_HEADERS) $(SDIR)/$(SUBMAKEFILE)
	@echo [NVCC] Compiling C++ $$(notdir $$<)
	$(Q)$(NVCC) --std=c++11 -dc $($(_MODULE)_CFLAGS) $$< -o $$@ $(LOGGING)

$(ODIR)/%$(OBJ_EXT): $(SDIR)/%.ptx $(SDIR)/$(SUBMAKEFILE)
	@echo [NVCC] Assembling $$(notdir $$<)
	$(Q)$(NVCC) $($(_MODULE)_AFLAGS) $$< -o $$@ $(LOGGING)
endef

ifneq ($(OLD_COMPILER),)
    ifeq ($(SHOW_MAKEDEBUG),1)
        $(info HOST_COMPILER reset to '$(OLD_COMPILER)')
    endif
    HOST_COMPILER:=$(strip $(OLD_COMPILER))
endif

endif
