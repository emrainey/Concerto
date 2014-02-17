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

# Tools
LATEX := latex
PDFLATEX := pdflatex
MSCGEN := mscgen
DOT := dot
EPSTOPDF := epstopdf

PDFNAME ?= $(TARGET).pdf

DOT_OBJS := $(DOTFILES:%.dot=$(ODIR)/%.pdf)
MSC_OBJS := $(MSCFILES:%.msc=$(ODIR)/%.pdf)
TEX_OBJS := $(TEXFILES:%.tex=$(ODIR)/%.pdf)

SUPPORT := $(BIBFILES) $(BSTFILES) $(STYFILES)
SUPPORT_SRCS := $(foreach sup,$(SUPPORT),$(SDIR)/$(sup))
SUPPORT_OBJS := $(foreach sup,$(SUPPORT),$(ODIR)/$(sup))

ifeq ($(SHOW_COMMANDS),1)
DFLAGS := --halt-on-error
endif

$(info Support LATEX Objects $(SUPPORT_OBJS))

$(_MODULE)_BIN := $(TDIR)/$(PDFNAME)
$(_MODULE)_SRCS := $(DOTFILES) $(MSCFILES) $(TEXFILES) $(BIBFILES) $(BSTFILES) $(STYFILES)
#$(_MODULE)_OBJS := $(DOT_OBJS) $(MSC_OBJS) $(TEX_OBJS)

$(info LATEX $(_MODULE)_BIN =  $($(_MODULE)_BIN))

define $(_MODULE)_DOTS
$(ODIR)/$(1).pdf: $(SDIR)/$(1).dot $(ODIR)/.gitignore
	@echo [DOT] $$(notdir $$<)
	$(Q)$(DOT) -Tpdf -o $$@ $$<
endef

define $(_MODULE)_MSCS
$(ODIR)/$(1).pdf: $(SDIR)/$(1).msc $(ODIR)/.gitignore
	@echo [MSC] $$(notdir $$<)
	$(Q)$(MSCGEN) -T eps -i $$< -o $$(basename $$@).eps
	$(Q)$(EPSTOPDF) $$(basename $$@).eps --outfile=$$@
endef

define $(_MODULE)_SUPPORT
$(ODIR)/$(1): $(SDIR)/$(1)
	$(Q)$(COPY) $$< $$@
endef

define $(_MODULE)_LATEX

build:: $($(_MODULE)_BIN)

$($(_MODULE)_BIN): $(TEX_OBJS)
	@echo [COPY] $$(notdir $$<)
	$(Q)$(COPY) $$< $$@

$(ODIR)/$(1).pdf: $(SDIR)/$(1).tex $(DOT_OBJS) $(MSC_OBJS) $(SUPPORT_OBJS) $(ODIR)/.gitignore
	@echo [TEX] $$(notdir $$<)
	$(Q)cd $(ODIR);$(PDFLATEX) $(DFLAGS) -output-format=pdf --output-directory=$(ODIR) $$<

endef

