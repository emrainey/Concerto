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

ifndef TIARMCGT_ROOT
$(error You must define TIARMCGT_ROOT!)
endif
ifndef XDC_ROOT
$(error You must define XDC_ROOT!)
endif
ifndef BIOS_ROOT
$(error You must define BIOS_ROOT!)
endif
ifndef IPC_ROOT
$(error You must define IPC_ROOT!)
endif

CC=armcl
CP=armcl
AS=armasm
AR=armar
LD=armlnk

ifdef LOGFILE
LOGGING:=&>$(LOGFILE)
else
LOGGING:=
endif

OBJ_EXT=oeA8F
LIB_PRE=
LIB_EXT=aA8F
ifeq ($(strip $($(_MODULE)_TYPE)),library)
	BIN_PRE=
	BIN_EXT=.$(LIB_EXT)
else ifeq ($(strip $($(_MODULE)_TYPE)),dsmo)
	BIN_PRE=
	BIN_EXT=.$(LIB_EXT)
else
	BIN_PRE=
	BIN_EXT=.$(LIB_EXT)
endif

$(_MODULE)_BIN  := $($(_MODULE)_TDIR)/$(BIN_PRE)$(TARGET)$(BIN_EXT)
$(_MODULE)_OBJS := $(ASSEMBLY:%.S=$($(_MODULE)_ODIR)/%.$(OBJ_EXT)) $(CPPSOURCES:%.cpp=$($(_MODULE)_ODIR)/%.$(OBJ_EXT)) $(CSOURCES:%.c=$($(_MODULE)_ODIR)/%.$(OBJ_EXT))
$(_MODULE)_ASM := $(ASSEMBLY:%.S=$($(_MODULE)_ODIR)/%.asm) $(CPPSOURCES:%.cpp=$($(_MODULE)_ODIR)/%.asm) $(CSOURCES:%.c=$($(_MODULE)_ODIR)/%.asm)
$(_MODULE)_NFO := $(ASSEMBLY:%.nfo=$($(_MODULE)_ODIR)/%.nfo) $(CPPSOURCES:%.cpp=$($(_MODULE)_ODIR)/%.nfo) $(CSOURCES:%.c=$($(_MODULE)_ODIR)/%.nfo)
# Redefine the local static libs and shared libs with REAL paths and pre/post-fixes
$(_MODULE)_STATIC_LIBS := $(foreach lib,$(STATIC_LIBS),$($(_MODULE)_TDIR)/$(LIB_PRE)$(lib).$(LIB_EXT))
$(_MODULE)_SHARED_LIBS := $(foreach lib,$(SHARED_LIBS),$($(_MODULE)_TDIR)/$(LIB_PRE)$(lib).$(LIB_EXT))
$(_MODULE)_COPT := --gcc

ifeq ($(TARGET_BUILD),debug)
$(_MODULE)_COPT += --opt_level=0 -g
else ifeq ($(TARGET_BUILD),release)
$(_MODULE)_COPT += --opt_level=3 --gen_opt_info=2
endif

ifeq ($(TARGET_CPU),ARM)
$(_MODULE)_COPT +=--endian=little --abi=eabi -mv=7A8  --float_support=vfpv3
endif

ifeq ($(CHECK_MISRA),1)
$(_MODULE)_COPT += --check_misra --misra_advisory=suppress
endif

$(_MODULE)_MAP      := -m=$($(_MODULE)_BIN).map
$(_MODULE)_INCLUDES := $(foreach inc,$($(_MODULE)_IDIRS),-I="$(basename $(inc))") $(foreach inc,$($(_MODULE)_SYSIDIRS),-I="$(basename $(inc))")
$(_MODULE)_DEFINES  := $(foreach def,$($(_MODULE)_DEFS),-d=$(def))
$(_MODULE)_LIBRARIES:= $(foreach ldir,$($(_MODULE)_LDIRS),--search_path="$(ldir)") $(foreach ldir,$($(_MODULE)_SYSLDIRS),--search_path="$(ldir)") $(foreach lib,$(STATIC_LIBS),--library=$(LIB_PRE)$(lib).$(LIB_EXT)) $(foreach lib,$(SYS_STATIC_LIBS),--library=$(LIB_PRE)$(lib).$(LIB_EXT))
$(_MODULE)_AFLAGS   := $($(_MODULE)_INCLUDES)
$(_MODULE)_LDFLAGS  := -z --warn_sections --reread_libs --rom_model
$(_MODULE)_CPLDFLAGS := $(foreach ldf,$($(_MODULE)_LDFLAGS), $(ldf))
$(_MODULE)_CFLAGS   := $($(_MODULE)_INCLUDES) $($(_MODULE)_DEFINES) $($(_MODULE)_COPT)

###################################################
# COMMANDS
###################################################

$(_MODULE)_CLEAN_OBJ  := $(CLEAN) $(call PATH_CONV,$($(_MODULE)_OBJS) $($(_MODULE)_ASM) $($(_MODULE)_NFO))
$(_MODULE)_CLEAN_BIN  := $(CLEAN) $(call PATH_CONV,$($(_MODULE)_BIN))
$(_MODULE)_LINK_LIB   := $(call PATH_CONV,$(AR) ru2 $($(_MODULE)_BIN) $($(_MODULE)_OBJS) $($(_MODULE)_STATIC_LIBS))
$(_MODULE)_LINK_EXE   := $(call PATH_CONV,$(AR) ru2 $($(_MODULE)_BIN) $($(_MODULE)_OBJS) $($(_MODULE)_STATIC_LIBS))

# $(call PATH_CONV,$(CP) $($(_MODULE)_CPLDFLAGS) -o $($(_MODULE)_BIN) $($(_MODULE)_OBJS) $($(_MODULE)_LIBRARIES) $($(_MODULE)_MAP) $($(_MODULE)_SDIR))

###################################################
# MACROS FOR COMPILING
###################################################

define $(_MODULE)_DEPEND_CC
# Do nothing...
endef

define $(_MODULE)_DEPEND_CP
# Do nothing...
endef

define $(_MODULE)_DEPEND_AS
# Do nothing...
endef

ifeq ($(strip $($(_MODULE)_TYPE)),prebuilt)

define $(_MODULE)_PREBUILT

$($(_MODULE)_SDIR)/$(1):

build:: $($(_MODULE)_SDIR)/$(1)

install:: $($(_MODULE)_TDIR)/$(notdir $(1))

$($(_MODULE)_TDIR)/$(notdir $(1)): $($(_MODULE)_SDIR)/$(1) $($(_MODULE)_ODIR)/.gitignore
	@echo Copying Prebuilt binary $($(_MODULE)_SDIR)/$(1) to $($(_MODULE)_TDIR)/$(notdir $(1))
	-$(Q)$(call PATH_CONV,$(COPY) $($(_MODULE)_SDIR)/$(1) $($(_MODULE)_TDIR)/$(notdir $(1)))
endef

else ifeq ($(strip $($(_MODULE)_TYPE)),library)

define $(_MODULE)_UNINSTALL
uninstall::
	@echo No uninstall step for static libraries
endef

define $(_MODULE)_INSTALL
install::
	@echo No install step for static libraries
endef

define $(_MODULE)_BUILD
build:: $($(_MODULE)_BIN)
endef

define $(_MODULE)_CLEAN_LNK
clean::
endef

else ifeq ($(strip $($(_MODULE)_TYPE)),dsmo)

define $(_MODULE)_UNINSTALL
uninstall::
	@echo No dynamic objects are supported!
endef

define $(_MODULE)_INSTALL
install::
	@echo No dynamic objects are supported!
endef

define $(_MODULE)_BUILD
$($(_MODULE)_BIN): $($(_MODULE)_OBJS) $($(_MODULE)_STATIC_LIBS) $($(_MODULE)_SHARED_LIBS)
	@echo Linking $$@
	-$(Q)$(call $(_MODULE)_LINK_LIB) $(LOGGING)

build:: $($(_MODULE)_BIN)
endef

define $(_MODULE)_CLEAN_LNK
clean::
	@echo No dynamic objects are supported!
endef

else ifeq ($(strip $($(_MODULE)_TYPE)),exe)

define $(_MODULE)_UNINSTALL
uninstall::
	@echo No uninstall step for $(TARGET_CPU)
endef

define $(_MODULE)_INSTALL
install::
	@echo No install step for $(TARGET_CPU)
endef

define $(_MODULE)_BUILD
build:: $($(_MODULE)_BIN)
endef

define $(_MODULE)_CLEAN_LNK
clean::
	@echo No clean link step defined!
endef

endif

ifeq ($(HOST_OS),Windows_NT)
define $(_MODULE)_COMPILE_TOOLS
$($(_MODULE)_ODIR)/%.$(OBJ_EXT): $($(_MODULE)_SDIR)/%.c $($(_MODULE)_ODIR)/.gitignore
	@echo [TIARM] Compiling C $$(notdir $$<)
	$(Q)$$(call PATH_CONV,$(CC) -c $($(_MODULE)_CFLAGS) -fr="$$(dir $$@)\" -fo=$$@ -fs="$$(dir $$@)\" -fp="$$<" $(LOGGING))

$($(_MODULE)_ODIR)/%.$(OBJ_EXT): $($(_MODULE)_SDIR)/%.cpp $($(_MODULE)_ODIR)/.gitignore
	@echo [TIARM] Compiling C++ $$(notdir $$<)
	$(Q)$$(call PATH_CONV,$(CP) -c $($(_MODULE)_CFLAGS) -fr="$$(dir $$@)\" -fo=$$@ -fs="$$(dir $$@)\" -fp="$$<" $(LOGGING))

$($(_MODULE)_ODIR)/%.$(OBJ_EXT): $($(_MODULE)_SDIR)/%.S $($(_MODULE)_ODIR)/.gitignore
	@echo [TIARM] Assembling $$(notdir $$<)
	$(Q)$$(call PATH_CONV,$(AS) -c $($(_MODULE)_AFLAGS) -fr="$$(dir $$@)" -fo=$$@ "$$<" $(LOGGING))
endef
else
define $(_MODULE)_COMPILE_TOOLS
$($(_MODULE)_ODIR)/%.$(OBJ_EXT): $($(_MODULE)_SDIR)/%.c $($(_MODULE)_ODIR)/.gitignore
	@echo [TIARM] Compiling C $$(notdir $$<)
	$(Q)$$(call PATH_CONV,$(CC) -c $($(_MODULE)_CFLAGS) -fr=$$(dir $$@) -eo=.$(OBJ_EXT) -fo=$$@ -fs=$$(dir $$@) -fc=$$< $(LOGGING))

$($(_MODULE)_ODIR)/%.$(OBJ_EXT): $($(_MODULE)_SDIR)/%.cpp $($(_MODULE)_ODIR)/.gitignore
	@echo [TIARM] Compiling C++ $$(notdir $$<)
	$(Q)$$(call PATH_CONV,$(CP) -c $($(_MODULE)_CFLAGS) -fr=$$(dir $$@) -eo=.$(OBJ_EXT) -fo=$$@ -fs=$$(dir $$@) -fp=$$< $(LOGGING))

$($(_MODULE)_ODIR)/%.$(OBJ_EXT): $($(_MODULE)_SDIR)/%.S $($(_MODULE)_ODIR)/.gitignore
	@echo [TIARM] Assembling $$(notdir $$<)
	$(Q)$$(call PATH_CONV,$(AS) -c $($(_MODULE)_AFLAGS) -fr=$$(dir $$@) -eo=.$(OBJ_EXT) -fo=$$@ -fa=$$< $(LOGGING))
endef

endif

