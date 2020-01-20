# It's necessary to set this because some environments don't link sh -> bash.
SHELL := /bin/bash
CUR_DIR := $(shell pwd)

all: presentation

.PHONY: presentation
presentation:
	pandoc \
	  --from=markdown \
	  --to=beamer \
	  --filter pandoc-latex-fontsize \
	  --filter pandoc-latex-color \
	  --filter pandoc-beamer-block \
	  --highlight-style highlight/my.theme \
	  --standalone \
	  --output=index.pdf \
	  --pdf-engine=pdflatex \
	  --slide-level 2\
	  theme-config.yaml index.md

.PHONY: setup
setup:
	pip install --user --quiet \
	  pandoc-latex-fontsize \
	  pandoc-latex-color \
	  pandoc-beamer-block

.PHONY: docker-image
docker-image: Dockerfile
	docker build --network host . -t talks/fosdem2020

.PHONY: with-docker
with-docker: docker-image
	docker run \
	  -it \
	  --rm \
	  -v $(CUR_DIR):/home/presenter/talk:Z \
	  -u $(shell id -u $(USER)):$(shell id -g $(USER)) \
	  talks/fosdem2020

