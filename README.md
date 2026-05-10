# CV LaTeX Project - Build Instructions

This project contains automated build scripts to compile your LaTeX CV and rename the output PDF with a specific name.

## Quick Start

### Option 1: Using the Makefile (Recommended)

```bash
# Build with default name (includes current date)
make

# Build with custom name
make OUTPUT_NAME=cv_hamza_jeddad_senior_ai_engineer

# Quick build (single pass, faster for minor changes)
make quick

# Clean auxiliary files
make clean

# Clean everything including PDFs
make cleanall

# Show help
make help
```

### Option 2: Using the Shell Script

```bash
# Build with default name (includes current date)
./build.sh

# Build with custom name
./build.sh cv_hamza_jeddad_senior_ai_engineer

# Build with custom name including date
./build.sh "cv_hamza_jeddad_$(date +%Y%m%d)"
```

## Output Naming

### Default Behavior
Both methods use a date-based naming convention by default:
- Format: `cv_hamza_jeddad_detailed_resume_en_YYYYMMDD.pdf`
- Example: `cv_hamza_jeddad_detailed_resume_en_20260409.pdf`

### Custom Names
You can specify any custom name:
```bash
# Using Makefile
make OUTPUT_NAME=resume_for_google
make OUTPUT_NAME=cv_senior_ml_engineer_2026

# Using shell script
./build.sh resume_for_google
./build.sh cv_senior_ml_engineer_2026
```

## Common Use Cases

### Daily builds with timestamps
```bash
make  # Automatically includes today's date
```

### Company-specific versions
```bash
make OUTPUT_NAME=cv_hamza_jeddad_google
make OUTPUT_NAME=cv_hamza_jeddad_meta
make OUTPUT_NAME=cv_hamza_jeddad_openai
```

### Role-specific versions
```bash
make OUTPUT_NAME=cv_hamza_jeddad_senior_ai_engineer
make OUTPUT_NAME=cv_hamza_jeddad_ml_engineer
make OUTPUT_NAME=cv_hamza_jeddad_data_scientist
```

## Files Generated

- `main.pdf` - Original compiled PDF (always generated)
- `[OUTPUT_NAME].pdf` - Renamed copy with your specified name
- Various auxiliary files (`.aux`, `.log`, `.synctex.gz`, etc.)

## Cleaning Up

```bash
# Remove auxiliary files only (keeps PDFs)
make clean

# Remove everything including all PDFs
make cleanall
```

## Requirements

- `pdflatex` - LaTeX compiler
- `bibtex` - Bibliography processor (if using citations)
- `make` - Build automation tool (for Makefile option)

## Troubleshooting

If you encounter permission issues with the shell script:
```bash
chmod +x build.sh
```

If compilation fails, check:
1. All required LaTeX packages are installed
2. The `main.tex` file is in the same directory
3. No syntax errors in your LaTeX code
