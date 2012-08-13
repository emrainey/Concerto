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
$(_MODULE)_BIN := $($(_MODULE)_TDIR)/$($(_MODULE)_TARGET).tar.gz

$(_MODULE)_HTML := docs/$(_MODULE)/html/index.html
$(_MODULE)_TEX  := docs/$(_MODULE)/latex/refman.tex
$(_MODULE)_PDF := docs/$(_MODULE)/latex/refman.pdf

define $(_MODULE)_DOCUMENTS

$($(_MODULE)_HTML): $($(_MODULE)_DOXYFILE)
	$(Q)rm -rf docs/$(_MODULE)/html
	$(Q)$(DOXYGEN) $($(_MODULE)_DOXYFILE)

$($(_MODULE)_TEX): $($(_MODULE)_DOXYFILE)
	$(Q)rm -rf docs/$(_MODULE)/latex
	$(Q)$(DOXYGEN) $($(_MODULE)_DOXYFILE)

$($(_MODULE)_PDF): $($(_MODULE)_TEX)
	$(Q)cd docs/$(_MODULE)/latex; make pdf

$(_MODULE)_docs: $($(_MODULE)_HTML) $($(_MODULE)_PDF)
	$(Q)tar zcvf $($(_MODULE)_BIN) docs/$(_MODULE)/html/ $($(_MODULE)_PDF)

docs:: $(_MODULE)_docs
	$(Q)echo Building docs for $(_MODULE)

endef

endif

