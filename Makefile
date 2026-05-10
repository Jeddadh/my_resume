# Makefile for LaTeX CV compilation with custom PDF naming
# Usage: make [OUTPUT_NAME=custom_name]

# Default output name (change this to your preferred default)
OUTPUT_NAME ?= cv_hamza_jeddad_detailed_resume_en_$(shell date +%Y%m%d)

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
		cp $(MAIN).pdf $(OUTPUT_NAME).pdf; \
		echo "PDF renamed to: $(OUTPUT_NAME).pdf"; \
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
		cp $(MAIN).pdf $(OUTPUT_NAME).pdf; \
		echo "Quick build complete: $(OUTPUT_NAME).pdf"; \
	fi

# Help target
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  make              - Compile and rename PDF (default)"
	@echo "  make OUTPUT_NAME=custom_name - Compile with custom output name"
	@echo "  make quick        - Quick single-pass compilation"
	@echo "  make clean        - Remove auxiliary files"
	@echo "  make cleanall     - Remove all generated files including PDFs"
	@echo "  make help         - Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make                                    # Uses date-based name"
	@echo "  make OUTPUT_NAME=resume_john_doe        # Custom name"
	@echo "  make OUTPUT_NAME=cv_senior_engineer     # Another custom name"
