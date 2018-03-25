SHELL := $(shell which bash) -O globstar -c

DOCUMENT := cv
LATEX_ARGS=-halt-on-error -shell-escape

FLAVOURS := pdflatex xelatex lualatex

DEFAULT_LATEX ?= xelatex

LANGUAGES := en

OUTDIR := pdf

INPUT_FILES = $(shell ls **/*.{tex,bib,cls} figures/**/*.{png,pdf,jpg,jpeg,svg,gif} 2>/dev/null)
OUTPUT_FILES := $(OUTDIR) $(DOCUMENT).pdf
AUX_FILES = $(shell ls **/*.{aux,dvi,thm,lof,log,lot,fls,out,toc,bbl,blg} 2>/dev/null)

$(OUTDIR)/$(DOCUMENT).pdf: $(OUTDIR)/$(DOCUMENT)-$(DEFAULT_LATEX).pdf
	@cp $^ $@

define compile_template

$(1): $(OUTDIR)/$$(DOCUMENT)-$(1).pdf
.PHONY: $(1)

$(OUTDIR)/$$(DOCUMENT)-$(1).pdf: $(INPUT_FILES) | $(OUTDIR)
	$(1) $$(MODE) $(LATEX_ARGS) $$(DOCUMENT)
	@mv $$(DOCUMENT).pdf $$@

endef

$(foreach _,$(FLAVOURS),$(eval $(call compile_template,$_)))

clean: clean-pdf clean-aux
.PHONY: clean

clean-pdf:
	@rm -rf $(DOCUMENT).pdf $(OUTDIR)
.PHONY: clean-pdf

clean-aux:
	@rm -f $(AUX_FILES)
.PHONY: clean-aux

watch:
	@echo Stop watching with Ctrl-C
	@sleep 1 # Wait a bit, so users can read
	@$(MAKE) || exit 0;
	@trap exit SIGINT; fswatch -o $(INPUT_FILES) | while read; do $(MAKE); done

.PHONY: watch

GH_REPO ?= szdavid92/cv
TGT_BRANCH ?= gh-pages
GIT_USER ?= "szdavid92"
GIT_EMAIL ?="david.szakallas@gmail.com"
COMMIT_MESSAGE ?="Update CV"

gh-upload: | $(OUTDIR)
	@OUTDIR=$| GH_TOKEN=$(GH_TOKEN) GH_REPO=$(GH_REPO)\
	 GIT_USER=$(GIT_USER) TGT_BRANCH=$(TGT_BRANCH) GIT_EMAIL=$(GIT_EMAIL) COMMIT_MESSAGE=$(COMMIT_MESSAGE)\
	 ./scripts/gh_upload.sh

$(OUTDIR):
	@mkdir -p $@

