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


ifeq ($($(_MODULE)_TYPE),opencl_kernel)

$(_MODULE)_TARGET := $(TARGET).h
$(_MODULE)_BIN    := $($(_MODULE)_SDIR)/$($(_MODULE)_TARGET)
$(_MODULE)_OBJS   := $($(_MODULE)_BIN)

ifeq ($(CL_BUILD_RUNTIME),)

# OpenCL-Environment Compiler Support
ifeq ($(HOST_OS),Windows_NT)
CL:=$($(_MODULE)_TDIR)/clcompiler.exe
else ifeq ($(HOST_OS),CYGWIN)
CL:=$($(_MODULE)_TDIR)/clcompiler.exe
else
CL:=$($(_MODULE)_TDIR)/clcompiler
endif

# OpenCL-Environment Defines
ifeq ($(HOST_OS),CYGWIN)
DEFS+=KDIR="\"$(KDIR)\"" CL_USER_DEVICE_COUNT=$(CL_USER_DEVICE_COUNT) CL_USER_DEVICE_TYPE="\"$(CL_USER_DEVICE_TYPE)\""
else ifeq ($(HOST_OS),Windows_NT)
DEFS+=KDIR="$(call PATH_CONV,$(KDIR))\\" CL_USER_DEVICE_COUNT=$(CL_USER_DEVICE_COUNT) CL_USER_DEVICE_TYPE="$(CL_USER_DEVICE_TYPE)"
else
DEFS+=KDIR="$(KDIR)" CL_USER_DEVICE_COUNT=$(CL_USER_DEVICE_COUNT) CL_USER_DEVICE_TYPE="$(CL_USER_DEVICE_TYPE)"
endif

ifeq ($(HOST_OS),CYGWIN)
# The Clang/LLVM is a Windows Path Compiler
$(_MODULE)_KFLAGS+=$(foreach inc,$($(_MODULE)_IDIRS),-I$(call P2W_CONV,$(inc))) $(foreach def,$($(_MODULE)_DEFS),-D$(def))
else
$(_MODULE)_KFLAGS+=$(foreach inc,$($(_MODULE)_IDIRS),-I$(inc)) $(foreach def,$($(_MODULE)_DEFS),-D$(def))
endif

define $(_MODULE)_COMPILE_TOOLS
$($(_MODULE)_SDIR)/%.h: $($(_MODULE)_SDIR)/%.cl $(CL)
	@echo [PURE] Compiling OpenCL Kernel $$(notdir $$<)
	$(Q)$$(call PATH_CONV,$(CL)) -n -f $$(call PATH_CONV,$$<) -d $(CL_USER_DEVICE_COUNT) -t $(CL_USER_DEVICE_TYPE) -h $$(call PATH_CONV,$$@) -W "$($(_MODULE)_KFLAGS)"
endef

else
define $(_MODULE)_COMPILE_TOOLS
$($(_MODULE)_SDIR)/%.h:
	@echo Touching $$@
	$(Q)$$(call $(TOUCH),$$@)
endef
endif
endif

