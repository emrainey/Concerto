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

ifeq ($($(_MODULE)_TYPE),jar)

JAR := jar
JAVAC := javac

###############################################################################

$(_MODULE)_BIN       := $(TDIR)/$($(_MODULE)_TARGET).jar
$(_MODULE)_CLASSES   := $(patsubst %.java,%.class,$(JSOURCES))
$(_MODULE)_OBJS      := $(foreach cls,$($(_MODULE)_CLASSES),$(ODIR)/$(cls))

ifeq ($(SHOW_MAKEDEBUG),1)
$(info Building JAR file $($(_MODULE)_BIN) from $($(_MODULE)_OBJS) which are $($(_MODULE)_CLASSES))
endif

ifdef CLASSPATH
$(_MODULE)_CLASSPATH := $(CLASSPATH) $(ODIR)
CLASSPATH            :=
else
$(_MODULE)_CLASSPATH := $(ODIR)
endif
ifneq ($($(_MODULE)_JAVA_LIBS),)
$(_MODULE)_JAVA_DEPS := $(foreach lib,$($(_MODULE)_JAVA_LIBS),$(TDIR)/$(lib).jar)
$(_MODULE)_CLASSPATH += $($(_MODULE)_JAVA_DEPS)
endif

ifeq ($(SHOW_MAKEDEBUG),1)
$(info CLASSPATH=$($(_MODULE)_CLASSPATH))
endif
$(_MODULE)_CLASSPATH := $(subst $(SPACE),:,$($(_MODULE)_CLASSPATH))
JC_OPTS              := -deprecation -classpath $($(_MODULE)_CLASSPATH) -sourcepath $(SDIR) -d $(ODIR)
ifeq ($(TARGET_BUILD),debug)
JC_OPTS              += -g -verbose
else ifneq ($(filter $(TARGET_BUILD),release production),)
# perform obfuscation?
endif

ifdef MANIFEST
$(_MODULE)_MANIFEST  := -m $(MANIFEST)
MANIFEST             :=
else
$(_MODULE)_MANIFEST  :=
endif
ifdef ENTRY
$(_MODULE)_ENTRY     := $(ENTRY)
ENTRY                :=
else
$(_MODULE)_ENTRY     := Main
endif
JAR_OPTS             := cvfe $($(_MODULE)_BIN) $($(_MODULE)_MANIFEST) $($(_MODULE)_ENTRY)

###############################################################################

define $(_MODULE)_BUILD
build:: $($(_MODULE)_BIN)
endef

define $(_MODULE)_COMPILE_TOOLS

$(ODIR)/%.class: $(SDIR)/%.java $(SDIR)/$(SUBMAKEFILE) $($(_MODULE)_JAVA_DEPS) $(ODIR)/.gitignore
	@echo Compiling Java $$(notdir $$<)
	$(Q)$(JAVAC) $(JC_OPTS) $$<

$($(_MODULE)_BIN): $($(_MODULE)_OBJS) $(SDIR)/$(SUBMAKEFILE)
	@echo Jar-ing all package classes in $$(notdir $$@)
	$(Q)$(JAR) $(JAR_OPTS) -C $($(_MODULE)_ODIR) .

endef

endif

