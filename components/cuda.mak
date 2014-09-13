# Copyright (C) 2014 Erik Rainey
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

ifeq ($(USE_CUDA),true)
    $(info CUDA Enabled)
    CUDA_LIBS := cudart cublas cufft curand cusparse nppc
    ifeq ($(HOST_OS),Windows_NT)
        ifeq ($(CUDA_ROOT),)
            $(error CUDA_ROOT must be defined to use CUDA)
        endif
        IDIRS += $(CUDA_ROOT)/include $(CUDA_ROOT)/inc
        LDIRS += $(CUDA_ROOT)/lib $(CUDA_ROOT)/lib64
        ifeq ($(filter $(PLATFORM_LIBS),$(CUDA_LIBS)),)
            PLATFORM_LIBS += $(CUDA_LIBS)
        endif
        DEFS += USE_CUDA __CUDA_API_VERSION=0x6000
    else ifeq ($(HOST_OS),LINUX)
        # User should install NVIDIA SDK
        ifeq ($(CUDA_ROOT),)
            ifneq ($(wildcard /usr/local/cuda/.*),)
                CUDA_ROOT := /usr/local/cuda
            else
                $(error CUDA_ROOT must be defined to use CUDA)
            endif
        endif
        IDIRS += $(CUDA_ROOT)/include
        LDIRS += $(CUDA_ROOT)/lib $(CUDA_ROOT)/lib64
        ifeq ($(filter $(PLATFORM_LIBS),$(CUDA_LIBS)),)
            PLATFORM_LIBS += $(CUDA_LIBS)
        endif
        DEFS += USE_CUDA
    else ifeq ($(HOST_OS),DARWIN)
        # User should have XCode install CUDA
        $(_MODULE)_FRAMEWORKS += -framework CUDA
        DEFS += USE_CUDA
    endif
endif
