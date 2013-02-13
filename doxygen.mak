# Copyright (C) 2012 Erik Rainey
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

ifeq ($($(_MODULE)_TYPE),doxygen)

DOXYGEN := doxygen
DOXYFILE ?= Doxyfile

$(_MODULE)_TARGET := $(TARGET)
$(_MODULE)_DOXYFILE := $($(_MODULE)_SDIR)/$(DOXYFILE)
$(_MODULE)_DOXYFILE_MOD := $(TARGET_DOC)/$(_MODULE)/$(DOXYFILE)
$(_MODULE)_BIN := $($(_MODULE)_TDIR)/$($(_MODULE)_TARGET).tar.gz

$(_MODULE)_HTML := $(TARGET_DOC)/$(_MODULE)/html/index.html
$(_MODULE)_TEX  := $(TARGET_DOC)/$(_MODULE)/latex/refman.tex
$(_MODULE)_PDF := $(TARGET_DOC)/$(_MODULE)/latex/refman.pdf

#$(info Modified Doxyfile should be in $($(_MODULE)_DOXYFILE_MOD))

define $(_MODULE)_DOCUMENTS

$(TARGET_DOC)/$(_MODULE)/.gitignore:
	$(Q)$(MKDIR) $(TARGET_DOC)/$(_MODULE)

$($(_MODULE)_DOXYFILE_MOD): $($(_MODULE)_DOXYFILE) $(TARGET_DOC)/$(_MODULE)/.gitignore
	$(Q)$(COPY) $($(_MODULE)_DOXYFILE) $(TARGET_DOC)/$(_MODULE)
	$(Q)$(PRINT) OUTPUT_DIRECTORY=$(TARGET_DOC)/$(_MODULE) >> $($(_MODULE)_DOXYFILE_MOD)
ifneq ($(SCM_VERSION),)
	-$(Q)$(PRINT) PROJECT_NUMBER=$(SCM_VERSION) >> $($(_MODULE)_DOXYFILE_MOD)
endif

$($(_MODULE)_HTML): $($(_MODULE)_DOXYFILE_MOD)
	$(Q)$(CLEANDIR) $(TARGET_DOC)/$(_MODULE)/html
	$(Q)$(DOXYGEN) $($(_MODULE)_DOXYFILE_MOD)

$($(_MODULE)_TEX): $($(_MODULE)_DOXYFILE_MOD)
	$(Q)$(CLEANDIR) $(TARGET_DOC)/$(_MODULE)/latex
	$(Q)$(DOXYGEN) $($(_MODULE)_DOXYFILE_MOD)

$($(_MODULE)_PDF): $($(_MODULE)_TEX)
	-$(Q)cd $(TARGET_DOC)/$(_MODULE)/latex; make pdf

$(_MODULE)_docs: $($(_MODULE)_HTML) $($(_MODULE)_PDF)
	$(Q)tar zcvf $($(_MODULE)_BIN) $(TARGET_DOC)/$(_MODULE)/html $($(_MODULE)_PDF)

$(_MODULE)_BIN: $(_MODULE)_docs

docs:: $(_MODULE)_docs
	$(Q)echo Building docs for $(_MODULE)

clean_docs::
	$(Q)$(CLEANDIR) docs/$(_MODULE)/latex
	$(Q)$(CLEANDIR) docs/$(_MODULE)/html

endef

endif

