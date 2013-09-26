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

ifeq ($(USE_GLUT),true)
	ifeq ($(HOST_OS),Wind	ows_NT)
		ifeq ($(GLUT_HOME),)
			$(error GLUT_HOME must be defined to use GLUT)
		endif
		IDIRS += $(GLUT_HOME)/include
		LDIRS += $(GLUT_HOME)/lib
		ifeq ($(filter $(PLATFORM_LIBS),glu32 glut),)
		    PLATFORM_LIBS += glut32 glut
		endif
	else ifeq ($(HOST_OS),LINUX)
		# User should install GLUT/Mesa via package system
		ifeq ($(filter $(PLATFORM_LIBS),glut GLU GL),)
			PLATFORM_LIBS += glut GLU GL
		endif
	else ifeq ($(HOST_OS),DARWIN)
		# User should have XCode install GLUT/OpenGL
		IDIRS+=/Developer/SDKs/MacOSX10.6.sdk/System/Library/Frameworks/OpenGL.framework/Headers
		IDIRS+=/Developer/SDKs/MacOSX10.6.sdk/System/Library/Frameworks/GLUT.framework/Headers
		$(_MODULE)_FRAMEWORKS +=-framework OpenGL -framework GLUT
	endif
endif