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

ifeq ($(TARGET_OS),LINUX)
    LIB_PRE:=lib
    LIB_EXT:=.a
    DSO_EXT:=.so
    OBJ_EXT:=.o
    PLATFORM_LIBS := dl pthread rt m
else ifeq ($(TARGET_OS),DARWIN)
    LIB_PRE:=lib
    LIB_EXT:=.a
    DSO_EXT:=.dylib
    OBJ_EXT:=.o
    EXE_EXT:=
    PLATFORM_LIBS := m
else ifeq ($(TARGET_OS),Windows_NT)
    LIB_PRE:=
    LIB_EXT:=.lib
    DSO_EXT:=.dll
    OBJ_EXT:=.obj
    EXE_EXT:=.exe
    PLATFORM_LIBS := Ws2_32 user32 kernel32 Gdi32
else ifeq ($(TARGET_OS),__QNX__)
    LIB_PRE:=lib
    LIB_EXT:=.a
    DSO_EXT:=.so
    OBJ_EXT:=.o
    EXE_EXT:=
    PLATFORM_LIBS := screen socket
else ifeq ($(TARGET_OS),CYGWIN)
    LIB_PRE:=lib
    LIB_EXT:=.a
    DSO_EXT:=.dll.a
    OBJ_EXT:=.o
    EXE_EXT:=.exe
    PLATFORM_LIBS := c pthread
else ifeq ($(TARGET_OS).SYSBIOS)
    LIB_PRE:=lib
    LIB_EXT:=.a
    DSO_EXT:=.a
    OBJ_EXT:=.obj
    EXE_EXT:=.out
    PLATFORM_LIBS :=
else ifeq ($(TARGET_OS),NO_OS)
    LIB_PRE:=lib
    LIB_EXT:=.a
    DSO_EXT:=.a
    OBJ_EXT:=.obj
    EXE_EXT:=.out
    PLATFORM_LIBS :=
endif
