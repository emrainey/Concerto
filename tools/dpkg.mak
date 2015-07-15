# Copyright (C) 2012 Erik Rainey
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

ifeq ($(TARGET_OS),LINUX)

CHECK_DPKG := $(shell which dpkg)
ifeq ($(SHOW_MAKEDEBUG),1)
$(info CHECK_DPKG=$(CHECK_DPKG))
endif
ifneq ($(CHECK_DPKG),)

PKG_EXT := .deb

VARS=$(shell "dpkg-architecture")
$(foreach var,$(VARS),$(if $(findstring DEB_BUILD_ARCH,$(var)),$(eval $(var))))

$(_MODULE)_CFG         ?= control
$(_MODULE)_PKG_NAME    := $(subst _,-,$($(_MODULE)_TARGET))
$(_MODULE)_PKG_FLDR    := $($(_MODULE)_ODIR)
$(_MODULE)_PKG         := $($(_MODULE)_PKG_NAME)$(PKG_EXT)
$(_MODULE)_BIN         := $($(_MODULE)_TDIR)/$($(_MODULE)_PKG)
$(_MODULE)_FILE_PATH   := $(FILE_PATH)
$(_MODULE)_FILES       := $(FILES)

ifeq ($(SHOW_MAKEDEBUG),1)
$(info $(_MODULE)_PKG_FLDR=$($(_MODULE)_PKG_FLDR))
endif

ifneq ($(filter-out 0 1,$(words $(INC_SUBPATH))),)
$(error INC_SUBPATH ($(INC_SUBPATH)) should have only 1 entry)
endif

# Remember that the INSTALL variable tend to be based in /
$(_MODULE)_PKG_LIB := $($(_MODULE)_PKG_FLDR)$($(_MODULE)_INSTALL_LIB)
$(_MODULE)_PKG_INC := $($(_MODULE)_PKG_FLDR)$($(_MODULE)_INSTALL_INC)/$($(_MODULE)_INC_SUBPATH)
$(_MODULE)_PKG_BIN := $($(_MODULE)_PKG_FLDR)$($(_MODULE)_INSTALL_BIN)
$(_MODULE)_PKG_CFG := $($(_MODULE)_PKG_FLDR)/DEBIAN
$(_MODULE)_PKG_FILE := $($(_MODULE)_PKG_FLDR)/$($(_MODULE)_FILE_PATH)

ifeq ($(SHOW_MAKEDEBUG),1)
$(info $(_MODULE)_PKG_LIB=$($(_MODULE)_PKG_LIB))
$(info $(_MODULE)_PKG_INC=$($(_MODULE)_PKG_INC))
$(info $(_MODULE)_PKG_BIN=$($(_MODULE)_PKG_BIN))
$(info $(_MODULE)_PKG_CFG=$($(_MODULE)_PKG_CFG))
$(info $(_MODULE)_PKG_FILE=$($(_MODULE)_PKG_FILE))
endif

# these package deps 
$(_MODULE)_PKG_DEPS:= $(foreach lib,$($(_MODULE)_SHARED_LIBS),$($(_MODULE)_PKG_LIB)/$(LIB_PRE)$(lib)$(DSO_EXT)) \
                         $(foreach lib,$($(_MODULE)_SHARED_LIBS),$($(_MODULE)_PKG_LIB)/$(LIB_PRE)$(lib)$(DSO_EXT).1.0) \
                         $(foreach lib,$($(_MODULE)_STATIC_LIBS),$($(_MODULE)_PKG_LIB)/$(LIB_PRE)$(lib)$(LIB_EXT)) \
                         $(foreach bin,$($(_MODULE)_BINS),$($(_MODULE)_PKG_BIN)/$(bin)$(EXE_EXT)) \
                         $(foreach inc,$($(_MODULE)_INCS),$($(_MODULE)_PKG_INC)/$(notdir $(inc))) \
                         $(foreach file,$($(_MODULE)_FILES),$($(_MODULE)_PKG_FILE)/$(notdir $(file)))

# Remove empty folders from list
$(_MODULE)_PKG_DEPS:=$(foreach dep,$($(_MODULE)_PKG_DEPS),$(if $(notdir $(dep)),$(dep),))

# Remove .gitignore files from list
$(_MODULE)_PKG_DEPS:=$(filter-out */.gitignore,$($(_MODULE)_PKG_DEPS))

ifeq ($(SHOW_MAKEDEBUG),1)
$(info Dependencies for $(_MODULE))
$(foreach dep,$($(_MODULE)_PKG_DEPS),$(info $(SPACE)$(SPACE)$(SPACE)$(SPACE)$(dep)))
endif

$(_MODULE)_OBJS := $($(_MODULE)_PKG_CFG)/$($(_MODULE)_CFG) $($(_MODULE)_PKG_DEPS)

ifeq ($(SHOW_MAKEDEBUG),1)
$(info $(_MODULE)_OBJS=$($(_MODULE)_OBJS))
endif

define $(_MODULE)_PACKAGE

$(foreach file,$($(_MODULE)_FILES),
$($(_MODULE)_PKG_FILE)/$(notdir $(file)): $(HOST_ROOT)/$($(_MODULE)_FILE_PATH)/$(notdir $(file)) $($(_MODULE)_SDIR)/$(SUBMAKEFILE) $($(_MODULE)_PKG_FILE)/.gitignore
	$(Q)$(COPY) $$< $$@
)

$(foreach lib,$($(_MODULE)_STATIC_LIBS),
$($(_MODULE)_PKG_LIB)/$(LIB_PRE)$(lib)$(LIB_EXT): $($(_MODULE)_TDIR)/$(LIB_PRE)$(lib)$(LIB_EXT) $($(_MODULE)_SDIR)/$(SUBMAKEFILE) $($(_MODULE)_PKG_LIB)/.gitignore
	$(Q)$(COPY) $$< $$@
)

$(foreach lib,$($(_MODULE)_SHARED_LIBS),
$($(_MODULE)_PKG_LIB)/$(LIB_PRE)$(lib)$(DSO_EXT): $($(_MODULE)_TDIR)/$(LIB_PRE)$(lib)$(DSO_EXT) $($(_MODULE)_SDIR)/$(SUBMAKEFILE) $($(_MODULE)_PKG_LIB)/.gitignore
	$(Q)$(COPY) $$< $$@
)

$(foreach lib,$($(_MODULE)_SHARED_LIBS),
$($(_MODULE)_TDIR)/$(LIB_PRE)$(lib)$(DSO_EXT).1.0: $($(_MODULE)_TDIR)/$(LIB_PRE)$(lib)$(DSO_EXT)
$($(_MODULE)_PKG_LIB)/$(LIB_PRE)$(lib)$(DSO_EXT).1.0: $($(_MODULE)_TDIR)/$(LIB_PRE)$(lib)$(DSO_EXT).1.0 $($(_MODULE)_SDIR)/$(SUBMAKEFILE) $($(_MODULE)_PKG_LIB)/.gitignore
	$(Q)$(COPY) $$< $$@
)

$(foreach bin,$($(_MODULE)_BINS),
$($(_MODULE)_PKG_BIN)/$(bin)$(EXE_EXT): $($(_MODULE)_TDIR)/$(bin)$(EXE_EXT) $($(_MODULE)_SDIR)/$(SUBMAKEFILE) $($(_MODULE)_PKG_BIN)/.gitignore
	$(Q)$(COPY) $$< $$@
)

$(foreach inc,$($(_MODULE)_INCS),
$($(_MODULE)_PKG_INC)/$(notdir $(inc)): $(inc) $($(_MODULE)_SDIR)/$(SUBMAKEFILE) $($(_MODULE)_PKG_INC)/.gitignore
	$(Q)$(COPY) $$< $$@
)

$($(_MODULE)_PKG_CFG)/$($(_MODULE)_CFG) : $($(_MODULE)_SDIR)/$($(_MODULE)_CFG) $($(_MODULE)_SDIR)/$(SUBMAKEFILE) $($(_MODULE)_PKG_CFG)/.gitignore
	$(Q)echo "Package: $($(_MODULE)_PKG_NAME)" > $$@
	$(Q)cat $($(_MODULE)_SDIR)/$($(_MODULE)_CFG) >> $$@
	$(Q)echo "Architecture: $(DEB_BUILD_ARCH)" >> $$@
	$(Q)echo "Provides: $($(_MODULE)_TARGET)" >> $$@

build:: $($(_MODULE)_BIN)

$($(_MODULE)_BIN): $($(_MODULE)_OBJS)
	$(Q)find $($(_MODULE)_ODIR) -name ".gitignore" -exec rm {} \;
	$(Q)dpkg --build $($(_MODULE)_ODIR) $$@

TESTABLE_MODULES += $(_MODULE)
TESTABLE_TARGETS += $($(_MODULE)_TARGET)_test
CONCERTO_TARGETS += $($(_MODULE)_TARGET)_test
CONCERTO_TARGETS += $($(_MODULE)_TARGET)_install
CONCERTO_TARGETS += $($(_MODULE)_TARGET)_remove
.PHONY: $($(_MODULE)_TARGET)_test
$($(_MODULE)_TARGET)_test: $($(_MODULE)_BIN)
	$(Q)sudo dpkg --dry-run -i $($(_MODULE)_BIN)

$($(_MODULE)_TARGET)_install: $($(_MODULE)_BIN)
	$(Q)sudo dpkg -i $$^

$($(_MODULE)_TARGET)_remove: $($(_MODULE)_BIN)
	$(Q)sudo dpkg -r $($(_MODULE)_TARGET)

endef

else
# This prevents non-dpkg system from worrying about packages
$(_MODULE)_BIN :=
endif
endif

