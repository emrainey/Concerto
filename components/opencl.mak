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

ifeq ($(USE_OPENCL),true)
	ifeq ($(HOST_OS),Windows_NT)
		ifeq ($(OPENCL_ROOT),)
			$(error OPENCL_ROOT must be defined to use OPENCL_ROOT)
		endif
		IDIRS += $(OPENCL_ROOT)/include $(OPENCL_ROOT)/inc
		LDIRS += $(OPENCL_ROOT)/lib $(OPENCL_ROOT)/lib64
		ifeq ($(filter $(PLATFORM_LIBS),OpenCL),)
		    PLATFORM_LIBS += OpenCL
		endif
	else ifeq ($(HOST_OS),LINUX)
		# User should install GLUT/Mesa via package system
		IDIRS += $(OPENCL_ROOT)/include $(OPENCL_ROOT)/inc
		LDIRS += $(OPENCL_ROOT)/lib $(OPENCL_ROOT)/lib64		
		ifeq ($(filter $(PLATFORM_LIBS),OpenCL),)
			PLATFORM_LIBS += OpenCL
		endif
	else ifeq ($(HOST_OS),DARWIN)
		# User should have XCode install OpenCL
		$(_MODULE)_FRAMEWORKS += -framework OpenCL
	endif
endif