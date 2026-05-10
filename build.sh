#!/bin/bash
# Simple build script for LaTeX CV with custom PDF naming
# Usage: ./build.sh [output_name]

# Default output name with timestamp
DEFAULT_NAME="cv_hamza_jeddad_detailed_resume_en_$(date +%Y%m%d)"
OUTPUT_NAME="${1:-$DEFAULT_NAME}"

echo "Building LaTeX document..."

# Compile LaTeX (multiple passes for references)
pdflatex -interaction=nonstopmode main.tex

# Check if bibtex is needed
if grep -q "\\citation" main.aux 2>/dev/null; then
    echo "Running bibtex..."
    bibtex main
    pdflatex -interaction=nonstopmode main.tex
fi

# Final pass
pdflatex -interaction=nonstopmode main.tex

# Rename the PDF
if [ -f "main.pdf" ]; then
    cp main.pdf "${OUTPUT_NAME}.pdf"
    echo "✓ PDF generated: ${OUTPUT_NAME}.pdf"
else
    echo "✗ Error: main.pdf not found!"
    exit 1
fi
