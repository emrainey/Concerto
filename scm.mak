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

ifeq ($(SCM_ROOT),)
SCM_ROOT := $(realpath .svn)
ifneq ($(SCM_ROOT),)
ifeq ($(BUILD_DEBUG),1)
$(info Subversion is used)
endif
SCM_VERSION := r$(word 2, $(shell svn info | grep Revision))
endif
endif

ifeq ($(SCM_ROOT),)
SCM_ROOT := $(realpath .git)
ifneq ($(SCM_ROOT),)
ifeq ($(BUILD_DEBUG),1)
$(info GIT is used)
endif
SCM_VERSION := $(shell git describe --tags --dirty)
endif
endif


