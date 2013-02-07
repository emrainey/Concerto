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

ifndef CGT6X_ROOT
$(error You must define CGT6X_ROOT!)
endif

ifndef XDC_ROOT
$(error You must define XDC_ROOT!)
endif

CC=$(CGT6X_ROOT)/bin/cl6x
CP=$(CGT6X_ROOT)/bin/cl6x
AS=$(CGT6X_ROOT)/bin/asm6x
AR=$(CGT6X_ROOT)/bin/ar6x
LD=$(CGT6X_ROOT)/bin/lnk6x

ifdef LOGFILE
LOGGING:=&>$(LOGFILE)
else
LOGGING:=
endif

ifeq ($(strip $($(_MODULE)_TYPE)),library)
	BIN_PRE=WTSD_TESLAMMSW.alg.
	BIN_EXT=.ae64T
else ifeq ($(strip $($(_MODULE)_TYPE)),dsmo)
	BIN_PRE=WTSD_TESLAMMSW.alg.
	BIN_EXT=.ae64T
else
	BIN_PRE=WTSD_TESLAMMSW.alg.
	BIN_EXT=.xe64T
endif

$(_MODULE)_BIN  := $($(_MODULE)_TDIR)/$(BIN_PRE)$(TARGET)$(BIN_EXT)
$(_MODULE)_OBJS := $(ASSEMBLY:%.asm=$($(_MODULE)_ODIR)/%.obj) $(CPPSOURCES:%.cpp=$($(_MODULE)_ODIR)/%.obj) $(CSOURCES:%.c=$($(_MODULE)_ODIR)/%.obj)
$(_MODULE)_ASM := $(ASSEMBLY:%.asm=$($(_MODULE)_ODIR)/%.asm) $(CPPSOURCES:%.cpp=$($(_MODULE)_ODIR)/%.asm) $(CSOURCES:%.c=$($(_MODULE)_ODIR)/%.asm)
$(_MODULE)_NFO := $(ASSEMBLY:%.nfo=$($(_MODULE)_ODIR)/%.nfo) $(CPPSOURCES:%.cpp=$($(_MODULE)_ODIR)/%.nfo) $(CSOURCES:%.c=$($(_MODULE)_ODIR)/%.nfo)
# Redefine the local static libs and shared libs with REAL paths and pre/post-fixes
$(_MODULE)_STATIC_LIBS := $(foreach lib,$(STATIC_LIBS),$($(_MODULE)_TDIR)/WTSD_TESLAMMSW.alg.$(lib).ae64T)
$(_MODULE)_SHARED_LIBS := $(foreach lib,$(SHARED_LIBS),$($(_MODULE)_TDIR)/WTSD_TESLAMMSW.alg.$(lib).ae64T)

$(_MODULE)_COPT := -pdr -k -mw -pdsw225 --mem_model:data=far
# -pdr     = Issues remarks (nonserious warnings)
# -k       = Keeps the assembly language (.asm) file
# -mw      = Produce verbose software pipelining report
# -pdsw225 =

ifeq ($(TARGET_BUILD),debug)
$(_MODULE)_COPT += --opt_level=0 -g
else ifeq ($(TARGET_BUILD),release)
$(_MODULE)_COPT += --opt_level=3 --gen_opt_info=2
endif

ifeq ($(TARGET_CPU),C64T)
$(_MODULE)_COPT +=-mvtesla -D=xdc_target_name__=C64T
else ifeq ($(TARGET_CPU),C64P)
$(_MODULE)_COPT +=-mv6400+ -D=xdc_target_name__=C64P
else ifeq ($(TARGET_CPU),C64X)
$(_MODULE)_COPT +=-mv6400
endif

$(_MODULE)_COPT +=-D=xdc_target_types__=ti/targets/elf/std.h -D=___DSPBIOS___

$(_MODULE)_MAP      := -m=$($(_MODULE)_BIN).map
$(_MODULE)_INCLUDES := $(foreach inc,$($(_MODULE)_IDIRS),-I=$(inc))
$(_MODULE)_DEFINES  := $(foreach def,$($(_MODULE)_DEFS),-D=$(def))
$(_MODULE)_LIBRARIES:= $(foreach ldir,$($(_MODULE)_LDIRS),--search_path=$(ldir)) $(foreach lib,$(STATIC_LIBS),--library=WTSD_TESLAMMSW.alg.$(lib).ae64T) $(foreach lib,$(SYS_STATIC_LIBS),--library=WTSD_TESLAMMSW.alg.$(lib).ae64T)
$(_MODULE)_AFLAGS   := $($(_MODULE)_INCLUDES)
$(_MODULE)_LDFLAGS  := -z --warn_sections --search_path="$(CGT6X_ROOT)/lib" -I="$(CGT6X_ROOT)/include" --reread_libs --rom_model
$(_MODULE)_CPLDFLAGS := $(foreach ldf,$($(_MODULE)_LDFLAGS), $(ldf))
$(_MODULE)_CFLAGS   := $($(_MODULE)_INCLUDES) $($(_MODULE)_DEFINES) $($(_MODULE)_COPT) -fs=$($(_MODULE)_ODIR) -I="$(CGT6X_ROOT)/include/" -I="$(XDC_ROOT)/packages/"


###################################################
# COMMANDS
###################################################

LINK := ln -s
CLEAN := rm -f
CLEANDIR := rm -rf
COPY := cp -f

$(_MODULE)_CLEAN_OBJ  := $(CLEAN) $($(_MODULE)_OBJS) $($(_MODULE)_ASM) $($(_MODULE)_NFO)
$(_MODULE)_CLEAN_BIN  := $(CLEAN) $($(_MODULE)_BIN)
$(_MODULE)_LINK_LIB   := $(AR) ru2 $($(_MODULE)_BIN) $($(_MODULE)_OBJS) #$($(_MODULE)_STATIC_LIBS)
$(_MODULE)_LINK_EXE   := $(CP) $($(_MODULE)_CPLDFLAGS) -o $($(_MODULE)_BIN) $($(_MODULE)_OBJS) $($(_MODULE)_LIBRARIES) $($(_MODULE)_MAP) $($(_MODULE)_SDIR)/$(LCMD)

###################################################
# MACROS FOR COMPILING
###################################################

define $(_MODULE)_DEPEND_CC

#$($(_MODULE)_ODIR)/$(1).d: $($(_MODULE)_SDIR)/$(1).c $($(_MODULE)_SDIR)/$(SUBMAKEFILE) $($(_MODULE)_ODIR)/.gitignore
#	@echo Generating  Dependency Info from $$(notdir $$<)
#	$(Q)$(CC) $($(_MODULE)_INCLUDES) -i"$(CGT6X_ROOT)/include" $($(_MODULE)_DEFINES) -ppd=$($(_MODULE)_ODIR)/$(1).d -fd=$($(_MODULE)_ODIR) $$< $(LOGGING)
#
#depend:: $($(_MODULE)_ODIR)/$(1).d
#
#-include $($(_MODULE)_ODIR)/$(1).d

endef

define $(_MODULE)_DEPEND_CP

#$($(_MODULE)_ODIR)/$(1).d: $($(_MODULE)_SDIR)/$(1).cpp $($(_MODULE)_SDIR)/$(SUBMAKEFILE) $($(_MODULE)_ODIR)/.gitignore
#	@echo Generating  Dependency Info from $$(notdir $$<)
#	$(Q)$(CC) $($(_MODULE)_INCLUDES) -i"$(CGT6X_ROOT)/include" $($(_MODULE)_DEFINES) -ppd=$($(_MODULE)_ODIR)/$(1).d -fd=$($(_MODULE)_ODIR) $$< $(LOGGING)
#
#depend:: $($(_MODULE)_ODIR)/$(1).d
#
#-include $($(_MODULE)_ODIR)/$(1).d

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
	-$(Q)$(COPY) $($(_MODULE)_SDIR)/$(1) $($(_MODULE)_TDIR)/$(notdir $(1))
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
	@echo No dynamic objects are supported !
endef

define $(_MODULE)_INSTALL
install::
	@echo No dynamic objects are supported !
endef

define $(_MODULE)_BUILD
build:: @echo No dynamic objects are supported !
endef

define $(_MODULE)_CLEAN_LNK
clean::
	@echo No dynamic objects are supported !
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
	@echo Building for $($(_MODULE)_BIN)
endef

define $(_MODULE)_CLEAN_LNK
clean::
endef

endif

define $(_MODULE)_COMPILE_TOOLS
$($(_MODULE)_ODIR)/%.obj: $($(_MODULE)_SDIR)/%.c $($(_MODULE)_ODIR)/.gitignore
	@echo [PURE] Compiling C99 $$(notdir $$<)
	$(Q)$(CC) -c $($(_MODULE)_CFLAGS) -fr=$$(dir $$@) $$< $(LOGGING)

$($(_MODULE)_ODIR)/%.obj: $($(_MODULE)_SDIR)/%.cpp $($(_MODULE)_ODIR)/.gitignore
	@echo [PURE] Compiling C++ $$(notdir $$<)
	$(Q)$(CP) -c $($(_MODULE)_CFLAGS) -fr=$$(dir $$@) $$< $(LOGGING)

$($(_MODULE)_ODIR)/%.obj: $($(_MODULE)_SDIR)/%.asm $($(_MODULE)_ODIR)/.gitignore
	@echo [PURE] Assembling $$(notdir $$<)
	$(Q)$(AS) -c $($(_MODULE)_AFLAGS) -fr=$$(dir $$@) $$< $(LOGGING)
endef
