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

ifeq ($(USE_SDL),true)
    ifeq ($(HOST_OS),Windows_NT)
        $(error SDL Not supported yet!)
    else ifeq ($(HOST_OS),LINUX)
        ifneq ($(SDL_PKG),)
            $(info Enable SDL)
            SDL_LIBS := $(subst -l,,$(shell pkg-config --libs-only-l $(SDL_PKG)))
            SDL_INCS := $(subst -I,,$(shell pkg-config --cflags-only-I $(SDL_PKG)))
            DEFS  += $(subst -D,,$(shell pkg-config --cflags-only-other $(SDL_PKG)))
            IDIRS += $(SDL_INCS)
            DEFS += USE_SDL
            SYS_SHARED_LIBS += $(SDL_LIBS)
        else
            $(error SDL_PKG is not set!)
        endif
    else ifeq ($(HOST_OS),DARWIN)
        $(error SDL not supported yet!)
    endif
endif
