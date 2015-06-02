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
JAVA := java

###############################################################################

$(_MODULE)_BIN       := $(TDIR)/$($(_MODULE)_TARGET).jar
$(_MODULE)_CLASSES   := $(patsubst %.java,%.class,$(JSOURCES))
$(_MODULE)_OBJS      := $(foreach cls,$($(_MODULE)_CLASSES),$(ODIR)/$(cls))
$(_MODULE)_PKGS      := $(sort $(foreach cls,$($(_MODULE)_CLASSES),$(dir $(cls))))

#$(foreach cls,$($(_MODULE)_CLASSES),$(info $(_MODULE) needs cls $(cls)))
#$(foreach obj,$($(_MODULE)_OBJS),$(info $(_MODULE) needs obj $(obj)))
#$(foreach pkg,$($(_MODULE)_PKGS),$(info $(_MODULE) has package $(pkg)))

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
else ifeq ($(TARGET_BUILD),release)
JC_OPTS              += -g:lines,vars
else ifeq ($(TARGET_BUILD),production)
JC_OPTS              += -g:none
else ifeq ($(TARGET_BUILD),profiling)
JC_OPTS              += -g
endif

$(_MODULE)_JAR_OPTS  := cvf
$(_MODULE)_ENTRY     := $(ENTRY)
ifdef MANIFEST
$(_MODULE)_JAR_OPTS  += m
$(_MODULE)_MANIFEST  := $(MANIFEST)
MANIFEST             :=
else
$(_MODULE)_MANIFEST  := $(ODIR)/Manifest.mf
$(_MODULE)_JAR_OPTS  += m

define $(_MODULE)_MANIFEST_PRODUCER
$($(_MODULE)_MANIFEST): $($(_MODULE)_JAVA_DEPS) $(SDIR)/$(SUBMAKEFILE) $(ODIR)/.gitignore
	$(PRINT) "Manifest-Version: 1.0" > $$@
ifneq ($($(_MODULE)_JAVA_LIBS),$(EMPTY))
	$(PRINT) "Class-Path: $(addsuffix .jar,$($(_MODULE)_JAVA_LIBS))" >> $$@
endif
ifneq ($(strip $($(_MODULE)_ENTRY)),$(EMPTY))
	$(PRINT) Using ENTRY=$($(_MODULE)_ENTRY)
	$(PRINT) "Main-Class: $($(_MODULE)_ENTRY)" >> $$@
endif
	$(PRINT) "Created-by: Concerto" >> $$@
endef

$(eval $(call $(_MODULE)_MANIFEST_PRODUCER))

endif

ifneq ($(strip $($(_MODULE)_ENTRY)),$(EMPTY))
ENTRY                :=
TESTABLE_MODULES     += $(_MODULE)
define $(_MODULE)_JAVA_TEST
.PHONY: $(_MODULE)_test
$(_MODULE)_test: $($(_MODULE)_BIN)
	$(Q)CLASSPATH=$(TDIR) $(JAVA) -jar $($(_MODULE)_BIN)
endef
$(eval $(call $(_MODULE)_JAVA_TEST))
endif

$(_MODULE)_JAR_OPTS  := $(call concat,$($(_MODULE)_JAR_OPTS))

###############################################################################

define $(_MODULE)_BUILD
build:: $($(_MODULE)_BIN)
endef

define $(_MODULE)_COMPILE_TOOLS

$(foreach pkg,$($(_MODULE)_PKGS),
$(ODIR)/$(pkg)%.class: $(SDIR)/$(pkg)%.java $(SDIR)/$(SUBMAKEFILE) $($(_MODULE)_JAVA_DEPS) $(ODIR)/.gitignore
	$(PRINT) Compiling Java $$(notdir $$<)
	$(Q)$(JAVAC) $(JC_OPTS) $$< $(LOGGING)
)

$($(_MODULE)_BIN): $($(_MODULE)_OBJS) $($(_MODULE)_MANIFEST) $(SDIR)/$(SUBMAKEFILE) $(TDIR)/.gitignore
	$(PRINT) Jar-ing all package classes in $$(notdir $$@)
	$(Q)$(JAR) $($(_MODULE)_JAR_OPTS) $($(_MODULE)_BIN) $($(_MODULE)_MANIFEST) -C $($(_MODULE)_ODIR) .
	$(Q)$(JAR) -i $$@ $(LOGGING)

endef

endif
