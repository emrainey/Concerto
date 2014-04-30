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

ifeq ($(USE_OPENMP),true)
	ifeq ($(HOST_OS),LINUX)
		CFLAGS += -fopenmp
		SYS_SHARED_LIBS += gomp
	else ifeq ($(HOST_OS),DARWIN)
		# User should have XCode install OpenMP
		$(_MODULE)_FRAMEWORKS += -framework OpenMP
	endif
endif
