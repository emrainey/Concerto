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

CC = CL
CP = CL
AS = $(TARGET_CPU)ASM
AR = LIB
LD = LINK

ifdef LOGFILE
LOGGING=>$(LOGFILE)
endif

ifeq ($(strip $(TARGETTYPE)),library)
	BIN_PRE=
	BIN_EXT=.lib
else ifeq ($(strip $(TARGETTYPE)),dsmo)
	BIN_PRE=
	BIN_EXT=.dll
else ifeq ($(strip $(TARGETTYPE)),exe)
	BIN_PRE=
	BIN_EXT=.exe
endif

$(_MODULE)_SYS_SHARED_LIBS += user32

$(_MODULE)_BIN  := $($(_MODULE)_TDIR)/$(BIN_PRE)$(TARGET)$(BIN_EXT)
$(_MODULE)_OBJS := $(ASSEMBLY:%.S=$($(_MODULE)_ODIR)/%.obj) $(CPPSOURCES:%.cpp=$($(_MODULE)_ODIR)/%.obj) $(CSOURCES:%.c=$($(_MODULE)_ODIR)/%.obj)
$(_MODULE)_STATIC_LIBS := $(foreach lib,$(STATIC_LIBS),$($(_MODULE)_TDIR)/$(lib).lib)
$(_MODULE)_SHARED_LIBS := $(foreach lib,$(SHARED_LIBS),$($(_MODULE)_TDIR)/$(lib).dll)
$(_MODULE)_PDB  := $($(_MODULE)_ODIR)/$(TARGET).pdb

$(_MODULE)_COPT+=/EHsc /W3
ifeq ($(TARGET_CPU),X64)
$(_MODULE)_COPT+=/Wp64
endif
ifeq ($(TARGET_BUILD),debug)
$(_MODULE)_COPT+=/Od /MDd /Gm /Zi /RTC1
else ifeq ($(TARGET_BUILD),release)
$(_MODULE)_COPT+=/Ox /MD
endif

$(_MODULE)_INCLUDES := $(foreach inc,$(call PATH_CONV,$($(_MODULE)_IDIRS)),/I$(inc))
$(_MODULE)_DEFINES  := $(foreach def,$($(_MODULE)_DEFS),/D$(def))
$(_MODULE)_LIBRARIES:= $(foreach ldir,$(call PATH_CONV,$($(_MODULE)_LDIRS)),/LIBPATH:$(ldir)) $(foreach lib,$(STATIC_LIBS),$(lib).lib) $(foreach lib,$(SHARED_LIBS),$(lib).lib) $(foreach lib,$(SYS_STATIC_LIBS),$(lib).lib) $(foreach lib,$(SYS_SHARED_LIBS),$(lib).lib)
$(_MODULE)_ARFLAGS  := /nologo /MACHINE:$(TARGET_CPU)
$(_MODULE)_AFLAGS   := $($(_MODULE)_INCLUDES)
$(_MODULE)_LDFLAGS  := /nologo /MACHINE:$(TARGET_CPU)
$(_MODULE)_CFLAGS   := /c /nologo $($(_MODULE)_INCLUDES) $($(_MODULE)_DEFINES) $($(_MODULE)_COPT) $(CFLAGS)

ifdef ENTRY
$(_MODULE)_ENTRY := $(ENTRY)
$(_MODULE)_LDFLAGS += /ENTRY:$($(_MODULE)_ENTRY) /SUBSYSTEM:WINDOWS
endif

ifdef DEFFILE
$(_MODULE)_DEF:=/DEF:$(call PATH_CONV,$($(_MODULE)_SDIR)/$(DEFFILE))
$(_MODULE)_DEPS:=$($(_MODULE)_SDIR)/$(DEFFILE)
else
$(_MODULE)_DEF:=
$(_MODULE)_DEPS:=
endif

ifeq ($(TARGET_BUILD),debug)
$(_MODULE)_LDFLAGS += /DEBUG
endif

###################################################
# COMMANDS
###################################################

$(_MODULE)_ATTRIB_EXE := $(ATTRIB) $(call PATH_CONV,$($(_MODULE)_BIN))
$(_MODULE)_LN_DS0 := $(SET_RW) $(call PATH_CONV,$($(_MODULE)_BIN))
$(_MODULE)_UNLN_DSO      := $(SET_RW) $(call PATH_CONV,$($(_MODULE)_BIN))
$(_MODULE)_INSTALL_DSO   := $(COPY) $(call PATH_CONV,$($(_MODULE)_TDIR)\\$($(_MODULE)_BIN)) $(call PATH_CONV,$($(_MODULE)_INSTALL_LIB))
$(_MODULE)_UNINSTALL_DSO := $(CLEAN) $(call PATH_CONV,$($(_MODULE)_INSTALL_LIB)\\$($(_MODULE)_BIN))
$(_MODULE)_INSTALL_EXE   := $(COPY) $(call PATH_CONV,$($(_MODULE)_TDIR)\\$($(_MODULE)_BIN)) $(call PATH_CONV,$($(_MODULE)_INSTALL_BIN))
$(_MODULE)_UNINSTALL_EXE := $(CLEAN) $(call PATH_CONV,$($(_MODULE)_INSTALL_BIN)\\$($(_MODULE)_BIN))
$(_MODULE)_LINK_LIB  := $(AR) $($(_MODULE)_ARFLAGS) /OUT:$(call PATH_CONV,$($(_MODULE)_BIN)) $(call PATH_CONV,$($(_MODULE)_OBJS)) $(call PATH_CONV,$($(_MODULE)_LIBS))
$(_MODULE)_LINK_EXE  := $(LD) $($(_MODULE)_LDFLAGS) $(call PATH_CONV,$($(_MODULE)_OBJS)) $($(_MODULE)_LIBRARIES) /OUT:$(call PATH_CONV,$($(_MODULE)_BIN))
$(_MODULE)_LINK_DSO  := $(LD) $($(_MODULE)_LDFLAGS) $(call PATH_CONV,$($(_MODULE)_OBJS)) $($(_MODULE)_LIBRARIES) /DLL $($(_MODULE)_DEF) /OUT:$(call PATH_CONV,$($(_MODULE)_BIN))

###################################################
# MACROS FOR COMPILING
###################################################

ifeq ($(strip $($(_MODULE)_TYPE)),library)

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
	@echo No clean link step for static libraries
endef

else ifeq ($(strip $($(_MODULE)_TYPE)),dsmo)

define $(_MODULE)_UNINSTALL
uninstall::
	@echo Uninstalling $$@
	-$(Q)$(call $(_MODULE)_UNLN_DSO)
	-$(Q)$(call $(_MODULE)_UNINSTALL_DSO)
endef

define $(_MODULE)_INSTALL
install::
	@echo Installing $($(_MODULE)_BIN)
	-$(Q)$(call $(_MODULE)_INSTALL_DSO)
	-$(Q)$(call $(_MODULE)_LN_DSO)
endef

define $(_MODULE)_BUILD
build:: $($(_MODULE)_BIN)
endef

define $(_MODULE)_CLEAN_LNK
clean::
	@echo Removing Link for Shared Object $($(_MODULE)_BIN).1.0
	-$(Q)$(CLEAN) $(call PATH_CONV,$($(_MODULE)_BIN).1.0)
endef

else ifeq ($(strip $($(_MODULE)_TYPE)),exe)

define $(_MODULE)_UNINSTALL
uninstall::
	-$(Q)$(call $(_MODULE)_UNINSTALL_EXE)
endef

define $(_MODULE)_INSTALL
install::
	@echo Installing $($(_MODULE)_BIN)
	-$(Q)$(call $(_MODULE)_INSTALL_EXE)
	-$(Q)$(call $(_MODULE)_ATTRIB_EXE)
endef

define $(_MODULE)_BUILD
build:: $($(_MODULE)_BIN)
	@echo Building for $($(_MODULE)_BIN)
endef

define $(_MODULE)_CLEAN_LNK
clean::
	@echo No clean link step for exes
endef

endif

define $(_MODULE)_COMPILE_TOOLS
$($(_MODULE)_ODIR)/%.obj: $($(_MODULE)_SDIR)/%.c
#	@echo [PURE] Compiling MSFT C $$(notdir $$<)
	$(Q)$(CC) $($(_MODULE)_CFLAGS) $$(call PATH_CONV,$$<) /Fo$$(call PATH_CONV,$$@) /Fd$$(call PATH_CONV,$($(_MODULE)_ODIR)/$$(notdir $$(basename $$<)).pdb) $(LOGGING)

$($(_MODULE)_ODIR)/%.obj: $($(_MODULE)_SDIR)/%.cpp
#	@echo [PURE] Compiling MSFT C++ $$(notdir $$<)
	$(Q)$(CP) $($(_MODULE)_CFLAGS) $$(call PATH_CONV,$$<) /Fo$$(call PATH_CONV,$$@) /Fd$$(call PATH_CONV,$($(_MODULE)_ODIR)/$$(notdir $$(basename $$<)).pdb) $(LOGGING)

$($(_MODULE)_ODIR)/%.obj: $($(_MODULE)_SDIR)/%.S
#	@echo [PURE] Assembling NASM $$(notdir $$<)
	$(Q)$(AS) $($(_MODULE)_AFLAGS) $$(call PATH_CONV,$$<) /Fo$$(call PATH_CONV,$$@) /Fd$$(call PATH_CONV,$($(_MODULE)_ODIR)/$$(notdir $$(basename $$<)).pdb)  $(LOGGING)
endef
