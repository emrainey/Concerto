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
        ifeq ($(TARGET_PLATFORM),PC)
            IDIRS += $(subst -I,$(EMPTY),$(shell pkg-config --cflags-only-I opencv))
            SYS_SHARED_LIBS += $(subst -l,$(EMPTY),$(shell pkg-config --libs opencv)) opencv_gpu
            DEFS += USE_OPENCV
        else ifeq ($(TARGET_PLATFORM),DEVBOARD)
            IDIRS += $(subst -I,$(EMPTY),$(shell pkg-config --cflags-only-I opencv))
            SYS_SHARED_LIBS += $(patsubst lib%,%,$(basename $(notdir $(subst -l,$(EMPTY),$(shell pkg-config --libs opencv)))))
            DEFS += USE_OPENCV
        endif
    endif
endif
