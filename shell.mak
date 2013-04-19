# Copyright (C) 2010 Erik Rainey
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

ifeq ($(HOST_OS),Windows_NT) # cmd.exe
CLEAN    := cmd.exe /C del /Q
CLEANDIR := cmd.exe /C rmdir /Q /S
COPY     := cmd.exe /C copy /Y /Z /V
PRINT    := @echo
SET_RW   := cmd.exe /C attrib -R
SET_EXEC := cmd.exe /C echo
LINK     := cmd.exe /C junction
TOUCH    := cmd.exe /C type NUL >
INSTALL  := cmd.exe /C copy /Y /Z /V
MKDIR    := cmd.exe /C mkdir
CAT      := cmd.exe /C type
else # Bash variants
CLEAN    := rm -f
CLEANDIR := rm -rf
COPY     := cp -f
PRINT    := @echo
SET_RW   := chmod a+rw
SET_EXEC := chmod a+x
LINK     := ln -s -f
TOUCH    := touch
INSTALL  := install -C -m 755
MKDIR    := mkdir -p
CAT      := cat
endif

