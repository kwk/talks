all:
	pandoc \
	  --from=markdown+grid_tables \
	  --to=beamer \
	  --filter pandoc-latex-fontsize \
	  --filter pandoc-latex-color \
	  --filter pandoc-beamer-block \
	  --highlight-style my.theme \
	  --standalone \
	  --output=index.pdf \
	  --pdf-engine=pdflatex \
	  --slide-level 2\
	  default.yaml index.md

.PHONY: embeddable
embeddable:
	pandoc \
	  --from=markdown \
	  --to=beamer \
	  --filter pandoc-latex-fontsize \
	  --filter pandoc-latex-color \
	  --filter pandoc-beamer-block \
	  --highlight-style espresso \
	  --output=pandoc-output.tex\
	  --pdf-engine=pdflatex \
	  default.yaml index.md

# List Highligh styles: pandoc --list-highlight-styles
# Highlight styles: https://www.garrickadenbuie.com/blog/pandoc-syntax-highlighting-examples/

.PHONY: setup
setup:
	pip install --user pandoc-latex-fontsize
	pip install --user pandoc-latex-color
	pip install --user pandoc-beamer-block

# --pdf-engine xelatex \
	  
