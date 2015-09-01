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

ifeq ($(USE_OPENCV),true)
    ifeq ($(SHOW_MAKEDEBUG),1)
        $(info OpenCV Enabled for $(_MODULE))
    endif

    ifeq ($(HOST_OS),LINUX)
        IDIRS += $(subst -I,$(EMPTY),$(shell pkg-config --cflags-only-I opencv))
        OPENCV_LIBS := $(patsubst lib%,%,$(basename $(notdir $(subst -l,$(EMPTY),$(shell pkg-config --libs-only-other opencv)))))
        # Remove opencv_ts as it has a PIC linking issue
        REMOVE_LIST := opencv_ts
        SYS_SHARED_LIBS += $(filter-out $(REMOVE_LIST),$(OPENCV_LIBS))
        DEFS += USE_OPENCV
    else ifeq ($(TARGET_OS),DARWIN)
    	OPENCV_ROOT ?= ../opencv
        SYS_SHARED_LIBS += $(addprefix opencv_, calib3d contrib core features2d flann highgui imgproc legacy ml objdetect ocl photo stitching superres video videostab)
        DEFS += USE_OPENCV
        SYSIDIRS += $(OPENCV_ROOT)/include
        SYSLDIRS += $(OPENCV_ROOT)/build/lib
    endif
endif
