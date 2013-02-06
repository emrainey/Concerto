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


ifeq ($($(_MODULE)_TYPE),deb)
ifeq ($(TARGET_OS),LINUX)

PKG_EXT := .deb

VARS=$(shell "dpkg-architecture")
$(foreach var,$(VARS),$(if $(findstring DEB_BUILD_ARCH,$(var)),$(eval $(var))))

#$(info OUT=$($(_MODULE)_ODIR))

$(_MODULE)_CFG         ?= control
$(_MODULE)_PKG_NAME    := $(subst _,-,$(TARGET))
$(_MODULE)_PKG_FLDR    := $($(_MODULE)_TDIR)/$($(_MODULE)_PKG_NAME)
$(_MODULE)_PKG         := $($(_MODULE)_PKG_NAME)$(PKG_EXT)
$(_MODULE)_BIN         := $($(_MODULE)_TDIR)/$($(_MODULE)_PKG)

#$(info OUT=$($(_MODULE)_PKG_FLDR))

# Remember that the INSTALL variable tend to be based in /
$(_MODULE)_PKG_LIB := $($(_MODULE)_PKG_FLDR)$($(_MODULE)_INSTALL_LIB)
$(_MODULE)_PKG_INC := $($(_MODULE)_PKG_FLDR)$($(_MODULE)_INSTALL_INC)/$($(_MODULE)_INC_SUBPATH)
$(_MODULE)_PKG_BIN := $($(_MODULE)_PKG_FLDR)$($(_MODULE)_INSTALL_BIN)
$(_MODULE)_PKG_CFG := $($(_MODULE)_PKG_FLDR)/DEBIAN

#$(info LIB=$($(_MODULE)_PKG_LIB))


$(_MODULE)_PKG_DEPS:= $(foreach lib,$($(_MODULE)_SHARED_LIBS),$($(_MODULE)_PKG_LIB)/lib$(lib).so) \
                      $(foreach lib,$($(_MODULE)_STATIC_LIBS),$($(_MODULE)_PKG_LIB)/lib$(lib).a) \
                      $(foreach bin,$($(_MODULE)_BINS),$($(_MODULE)_PKG_BIN)/$(bin)) \
                      $(foreach inc,$($(_MODULE)_INCS),$($(_MODULE)_PKG_INC)/$(notdir $(inc)))

#$(info $(_MODULE)_PKG_DEPS=$($(_MODULE)_PKG_DEPS))

$(_MODULE)_OBJS := $($(_MODULE)_PKG_CFG)/$($(_MODULE)_CFG) $($(_MODULE)_PKG_DEPS)

#$(info $(_MODULE)_OBJS=$($(_MODULE)_OBJS))

$(_MODULE)_CLEAN_BIN = rm -f $($(_MODULE)_BIN)
$(_MODULE)_CLEAN_OBJ = rm -f $($(_MODULE)_OBJS)

define $(_MODULE)_PACKAGE

$(foreach lib,$($(_MODULE)_STATIC_LIBS),
$($(_MODULE)_PKG_LIB)/lib$(lib).a: $($(_MODULE)_TDIR)/lib$(lib).a
	$(Q)mkdir -p $$(dir $$@)
	$(Q)cp $$^ $$@
)

$(foreach lib,$($(_MODULE)_SHARED_LIBS),
$($(_MODULE)_PKG_LIB)/lib$(lib).so: $($(_MODULE)_TDIR)/lib$(lib).so
	$(Q)mkdir -p $$(dir $$@)
	$(Q)cp $$^ $$@
)

$(foreach bin,$($(_MODULE)_BINS),
$($(_MODULE)_PKG_BIN)/$(bin): $($(_MODULE)_TDIR)/$(bin)
	$(Q)mkdir -p $$(dir $$@)
	$(Q)cp $$^ $$@
)

$(foreach inc,$($(_MODULE)_INCS),
$($(_MODULE)_PKG_INC)/$(notdir $(inc)): $(inc)
	$(Q)mkdir -p $$(dir $$@)
	$(Q)cp $$^ $$@
)

$($(_MODULE)_PKG_CFG)/$($(_MODULE)_CFG) : $($(_MODULE)_SDIR)/$($(_MODULE)_CFG) $($(_MODULE)_ODIR)/.gitignore
	$(Q)mkdir -p $($(_MODULE)_PKG_LIB)
	$(Q)mkdir -p $($(_MODULE)_PKG_INC)
	$(Q)mkdir -p $($(_MODULE)_PKG_BIN)
	$(Q)mkdir -p $($(_MODULE)_PKG_CFG)
	$(Q)echo "Package: $($(_MODULE)_PKG_NAME)" > $$@
	$(Q)cat $($(_MODULE)_SDIR)/$($(_MODULE)_CFG) >> $$@
	$(Q)echo "Architecture: $(DEB_BUILD_ARCH)" >> $$@

build:: $($(_MODULE)_BIN)

$($(_MODULE)_BIN): $($(_MODULE)_OBJS)
	$(Q)dpkg --build $$(basename $$@)
endef

else
# This prevents non-linux system from worrying about packages
$(_MODULE)_BIN :=
endif
endif

