# Makefile for LaTeX CV compilation with automatic customer folder detection
#
# The PDF is automatically output into a folder matching the current Git branch,
# and the PDF file itself is also named after the branch.
# This way: one branch = one customer = one folder = one PDF with matching name.
#
# Usage:
#   make                          # Auto: PDF named after branch, in branch folder
#   make CUSTOMER=                # Override: output to root
#   make OUTPUT_NAME=custom_name  # Custom filename
#
# Examples:
#   make                                    # 2026.05.algovia.airbus/2026.05.algovia.airbus.pdf
#   make CUSTOMER=                          # Root, date-based name
#   make OUTPUT_NAME=cv_daisei              # Branch folder, custom name

# Auto-detect branch and customer folder from current Git branch
# On main/master, outputs to root with date-based name
BRANCH := $(shell git branch --show-current 2>/dev/null)

# Default output name — PDF name = branch name
ifeq ($(BRANCH),main)
OUTPUT_NAME ?= cv_hamza_jeddad_detailed_resume_en_$(shell date +%Y%m%d)
CUSTOMER ?=
else ifeq ($(BRANCH),master)
OUTPUT_NAME ?= cv_hamza_jeddad_detailed_resume_en_$(shell date +%Y%m%d)
CUSTOMER ?=
else
OUTPUT_NAME ?= $(BRANCH)
CUSTOMER ?= $(BRANCH)
endif

# Allow manual override of CUSTOMER (e.g. make CUSTOMER= to force root)
ifneq ($(origin CUSTOMER),undefined)
  ifeq ($(CUSTOMER),)
    OUTDIR = .
  else
    OUTDIR = $(CUSTOMER)
  endif
else
  ifeq ($(CUSTOMER),)
    OUTDIR = .
  else
    OUTDIR = $(CUSTOMER)
  endif
endif

# Full output path
OUTPUT_PATH = $(OUTDIR)/$(OUTPUT_NAME).pdf

# LaTeX compiler settings
LATEX = pdflatex
BIBTEX = bibtex
MAIN = main

# Default target
.PHONY: all
all: compile rename

# Compile the LaTeX document
.PHONY: compile
compile:
	@echo "Compiling LaTeX document..."
	$(LATEX) -interaction=nonstopmode $(MAIN).tex
	@if grep -q "\\citation" $(MAIN).aux 2>/dev/null; then \
		echo "Running bibtex..."; \
		$(BIBTEX) $(MAIN); \
		$(LATEX) -interaction=nonstopmode $(MAIN).tex; \
	fi
	$(LATEX) -interaction=nonstopmode $(MAIN).tex
	@echo "Compilation complete!"

# Rename the output PDF
.PHONY: rename
rename:
	@if [ -f "$(MAIN).pdf" ]; then \
		mkdir -p $(OUTDIR); \
		cp $(MAIN).pdf $(OUTPUT_PATH); \
		echo "PDF copied to: $(OUTPUT_PATH)"; \
	else \
		echo "Error: $(MAIN).pdf not found!"; \
		exit 1; \
	fi

# Clean auxiliary files
.PHONY: clean
clean:
	@echo "Cleaning auxiliary files..."
	rm -f $(MAIN).aux $(MAIN).log $(MAIN).out $(MAIN).toc \
	      $(MAIN).bbl $(MAIN).blg $(MAIN).bcf $(MAIN).run.xml \
	      $(MAIN).fls $(MAIN).fdb_latexmk $(MAIN).synctex.gz
	@echo "Clean complete!"

# Clean everything including PDFs
.PHONY: cleanall
cleanall: clean
	@echo "Removing all PDF files..."
	rm -f $(MAIN).pdf cv_*.pdf
	@echo "All files removed!"

# Quick build (single pass, for minor changes)
.PHONY: quick
quick:
	$(LATEX) -interaction=nonstopmode $(MAIN).tex
	@if [ -f "$(MAIN).pdf" ]; then \
		mkdir -p $(OUTDIR); \
		cp $(MAIN).pdf $(OUTPUT_PATH); \
		echo "Quick build complete: $(OUTPUT_PATH)"; \
	fi

# Help target
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  make              - Auto: PDF named after branch, in branch folder"
	@echo "  make CUSTOMER=    - Override: output to root instead"
	@echo "  make OUTPUT_NAME=... - Custom output filename"
	@echo "  make quick        - Quick single-pass compilation"
	@echo "  make clean        - Remove auxiliary files"
	@echo "  make cleanall     - Remove all generated files including PDFs"
	@echo "  make help         - Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make                        # 2026.05.algovia.airbus/2026.05.algovia.airbus.pdf"
	@echo "  make CUSTOMER=              # Override: root output"
	@echo "  make OUTPUT_NAME=cv_daisei  # Custom name in branch folder"
