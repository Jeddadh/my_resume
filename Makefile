# Makefile for LaTeX CV compilation with automatic customer folder detection
#
# Behavior:
#   - On a feature branch (e.g. 2026.05.algovia.airbus):
#       Finds all .tex files inside the branch folder, compiles each one,
#       and outputs the PDF(s) in the same folder.
#   - On main/master:
#       Compiles main.tex from root and outputs to root.
#
# Usage:
#   make                          # Auto-detect and compile
#   make CUSTOMER=                # Force root mode
#   make clean                    # Remove auxiliary files

# Auto-detect branch
BRANCH := $(shell git branch --show-current 2>/dev/null)

# Determine mode
ifeq ($(BRANCH),main)
MODE := root
else ifeq ($(BRANCH),master)
MODE := root
else
MODE := customer
endif

# LaTeX compiler settings
LATEX = pdflatex
BIBTEX = bibtex
MAIN = main

# Default target: compile all .tex in the relevant folder
.PHONY: all
all:
ifneq ($(origin CUSTOMER),undefined)
	$(MAKE) compile-customer CUSTOMER=$(CUSTOMER)
else ifeq ($(MODE),root)
	$(MAKE) compile-root
else
	$(MAKE) compile-customer CUSTOMER=$(BRANCH)
endif

# Compile main.tex from root
.PHONY: compile-root
compile-root:
	@echo "=== Compiling main.tex (root mode) ==="
	$(LATEX) -interaction=nonstopmode $(MAIN).tex
	@if grep -q "\\citation" $(MAIN).aux 2>/dev/null; then \
		echo "Running bibtex..."; \
		$(BIBTEX) $(MAIN); \
		$(LATEX) -interaction=nonstopmode $(MAIN).tex; \
	fi
	$(LATEX) -interaction=nonstopmode $(MAIN).tex
	@echo "=== Done: main.pdf ==="

# Compile all .tex files inside a customer folder
# Compiles from root (so altacv.cls is found) but outputs into the customer folder
# Usage: make compile-customer CUSTOMER=folder_name
.PHONY: compile-customer
compile-customer:
	@echo "=== Compiling .tex files in $(CUSTOMER)/ ==="
	@TEX_FILES=$$(ls $(CUSTOMER)/*.tex 2>/dev/null); \
	if [ -z "$$TEX_FILES" ]; then \
		echo "No .tex files found in $(CUSTOMER)/"; \
		exit 1; \
	fi; \
	for tex in $$TEX_FILES; do \
		base=$$(basename "$$tex" .tex); \
		echo ""; \
		echo "--- Compiling $$base.tex (output to $(CUSTOMER)/) ---"; \
		$(LATEX) -interaction=nonstopmode -output-directory=$(CUSTOMER) $${tex}; \
		if grep -q "\\citation" $(CUSTOMER)/$$base.aux 2>/dev/null; then \
			cd $(CUSTOMER) && $(BIBTEX) $$base && cd ..; \
			$(LATEX) -interaction=nonstopmode -output-directory=$(CUSTOMER) $${tex}; \
		fi; \
		$(LATEX) -interaction=nonstopmode -output-directory=$(CUSTOMER) $${tex}; \
		echo "--- Done: $(CUSTOMER)/$$base.pdf ---"; \
	done
	@echo "=== All compilations complete ==="

# Clean auxiliary files
.PHONY: clean
clean:
	@echo "Cleaning auxiliary files from root..."
	rm -f $(MAIN).aux $(MAIN).log $(MAIN).out $(MAIN).toc \
	      $(MAIN).bbl $(MAIN).blg $(MAIN).bcf $(MAIN).run.xml \
	      $(MAIN).fls $(MAIN).fdb_latexmk $(MAIN).synctex.gz
ifneq ($(BRANCH),main)
ifneq ($(BRANCH),master)
	@echo "Cleaning auxiliary files from $(BRANCH)/..."
	rm -f $(BRANCH)/*.aux $(BRANCH)/*.log $(BRANCH)/*.out $(BRANCH)/*.toc \
	      $(BRANCH)/*.bbl $(BRANCH)/*.blg $(BRANCH)/*.bcf $(BRANCH)/*.run.xml \
	      $(BRANCH)/*.fls $(BRANCH)/*.fdb_latexmk $(BRANCH)/*.synctex.gz
endif
endif
	@echo "Clean complete!"

# Clean everything including PDFs
.PHONY: cleanall
cleanall: clean
	@echo "Removing root PDFs..."
	rm -f $(MAIN).pdf cv_*.pdf
ifneq ($(BRANCH),main)
ifneq ($(BRANCH),master)
	@echo "Removing customer folder PDFs..."
	rm -f $(BRANCH)/*.pdf
endif
endif
	@echo "All files removed!"

# Help target
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  make              - Auto: compile .tex files in current branch folder"
	@echo "  make CUSTOMER=    - Override: compile main.tex from root"
	@echo "  make clean        - Remove auxiliary files"
	@echo "  make cleanall     - Remove all generated files including PDFs"
	@echo "  make help         - Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make                        # Compiles all .tex in 2026.05.algovia.airbus/"
	@echo "  make CUSTOMER=              # Compiles main.tex from root"
