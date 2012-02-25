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

# Add the paths from the makefile
$(_MODULE)_IDIRS += $(SYSIDIRS) $(IDIRS)
$(_MODULE)_LDIRS += $(SYSLDIRS) $(LDIRS)

# Add any additional libraries which are in this build system
$(_MODULE)_STATIC_LIBS += $(STATIC_LIBS)
$(_MODULE)_SHARED_LIBS += $(SHARED_LIBS)
$(_MODULE)_SYS_STATIC_LIBS += $(SYS_STATIC_LIBS)
$(_MODULE)_SYS_SHARED_LIBS += $(SYS_SHARED_LIBS)

# Copy over the rest of the variables
$(_MODULE)_TYPE := $(TARGETTYPE)
$(_MODULE)_DEFS := $(SYSDEFS) $(DEFS)
$(_MODULE)_TEST := $(TESTCASE)

# Set the Install Path
$(_MODULE)_INSTALL_PATH = $(INSTALL_PATH)

# For debugging the build system
$(_MODULE)_SRCS := $(CSOURCES) $(CPPSOURCES) $(ASSEMBLY) $(JSOURCES)

ifndef SKIPBUILD

ifeq ($(HOST_COMPILER),GCC)
	include $(HOST_ROOT)/$(BUILD_FOLDER)/gcc.mak
else ifeq ($(HOST_COMPILER),CL)
	include $(HOST_ROOT)/$(BUILD_FOLDER)/cl.mak
else ifeq ($(HOST_COMPILER),CGT6X)
	include $(HOST_ROOT)/$(BUILD_FOLDER)/cgt6x.mak
else ifeq ($(HOST_COMPILER),QCC)
	include $(HOST_ROOT)/$(BUILD_FOLDER)/qcc.mak
endif

include $(HOST_ROOT)/$(BUILD_FOLDER)/java.mak

else

$(info Build Skipped for $(_MODULE))

all %::

endif  # ifndef SKIPBUILD


###################################################
# RULES
###################################################

$(_MODULE): $($(_MODULE)_BIN)

.PHONY: $(_MODULE)_test
$(_MODULE)_test: install
	$($(_MODULE)_TEST)

ifeq ($(strip $($(_MODULE)_TYPE)),library)

define $(_MODULE)_BUILD_LIB
$($(_MODULE)_BIN): $($(_MODULE)_OBJS) $($(_MODULE)_STATIC_LIBS)
	@echo Linking $$@
	-$(Q)$(call $(_MODULE)_LINK_LIB) $(LOGGING)
endef

$(eval $(call $(_MODULE)_BUILD_LIB))
$(eval $(call $(_MODULE)_INSTALL))
$(eval $(call $(_MODULE)_BUILD))
$(eval $(call $(_MODULE)_UNINSTALL))

else ifeq ($(strip $($(_MODULE)_TYPE)),exe)

define $(_MODULE)_BUILD_EXE
$($(_MODULE)_BIN): $($(_MODULE)_OBJS) $($(_MODULE)_STATIC_LIBS) $($(_MODULE)_SHARED_LIBS)
	@echo Linking $$@
	-$(Q)$(call $(_MODULE)_LINK_EXE) $(LOGGING)
endef

$(eval $(call $(_MODULE)_BUILD_EXE))
$(eval $(call $(_MODULE)_INSTALL))
$(eval $(call $(_MODULE)_BUILD))
$(eval $(call $(_MODULE)_UNINSTALL))

else ifeq ($(strip $($(_MODULE)_TYPE)),dsmo)

define $(_MODULE)_BUILD_DSO
$($(_MODULE)_BIN): $($(_MODULE)_OBJS) $($(_MODULE)_STATIC_LIBS) $($(_MODULE)_SHARED_LIBS)
	@echo Linking $$@
	$(Q)$(call $(_MODULE)_LINK_DSO) $(LOGGING)
	-$(Q)$(call $(_MODULE)_LN_DSO)
endef

$(eval $(call $(_MODULE)_BUILD_DSO))
$(eval $(call $(_MODULE)_INSTALL))
$(eval $(call $(_MODULE)_BUILD))
$(eval $(call $(_MODULE)_UNINSTALL))

else ifeq ($(strip $($(_MODULE)_TYPE)),objects)

$($(_MODULE)_BIN): $($(_MODULE)_OBJS)

else ifeq ($(strip $($(_MODULE)_TYPE)),prebuilt)

$(eval $(call $(_MODULE)_PREBUILT,$(PREBUILT)))

else ifeq ($(strip $($(_MODULE)_TYPE)),jar)

$(eval $(call $(_MODULE)_DEPEND_JAR))

endif

define $(_MODULE)_CLEAN
.PHONY: clean_bin clean
clean_target::
	@echo Cleaning $($(_MODULE)_BIN)
	-$(Q)$(call $(_MODULE)_CLEAN_BIN)

clean:: clean_target
	@echo Cleaning $($(_MODULE)_OBJS)
	-$(Q)$(call $(_MODULE)_CLEAN_OBJ)
endef

$(eval $(call $(_MODULE)_CLEAN))
$(eval $(call $(_MODULE)_CLEAN_LNK))
$(foreach obj,$(CSOURCES),  $(eval $(call $(_MODULE)_DEPEND_CC,$(basename $(obj)))))
$(foreach obj,$(CPPSOURCES),$(eval $(call $(_MODULE)_DEPEND_CP,$(basename $(obj)))))
$(foreach obj,$(ASSEMBLY),  $(eval $(call $(_MODULE)_DEPEND_AS,$(basename $(obj)))))
$(foreach cls,$(JSOURCES),  $(eval $(call $(_MODULE)_DEPEND_CLS,$(basename $(cls)))))

$(eval $(call $(_MODULE)_COMPILE_TOOLS))

define $(_MODULE)_VARDEF
$(_MODULE)_vars::
	@echo =============================================
	@echo _MODULE=$(_MODULE)
	@echo $(_MODULE)_BIN =$($(_MODULE)_BIN)
	@echo $(_MODULE)_TYPE=$($(_MODULE)_TYPE)
	@echo $(_MODULE)_OBJS=$($(_MODULE)_OBJS)
	@echo $(_MODULE)_SDIR=$($(_MODULE)_SDIR)
	@echo $(_MODULE)_ODIR=$($(_MODULE)_ODIR)
	@echo $(_MODULE)_TDIR=$($(_MODULE)_TDIR)
	@echo $(_MODULE)_SRCS=$($(_MODULE)_SRCS)
	@echo $(_MODULE)_STATIC_LIBS=$($(_MODULE)_STATIC_LIBS)
	@echo $(_MODULE)_SHARED_LIBS=$($(_MODULE)_SHARED_LIBS)
	@echo $(_MODULE)_SYS_SHARED_LIBS=$($(_MODULE)_SYS_SHARED_LIBS)
	@echo $(_MODULE)_CLASSES=$($(_MODULES)_CLASSES)
	@echo =============================================
endef

$(eval $(call $(_MODULE)_VARDEF))

# Now clear out the module variable for repeat definitions
_MODULE := 

