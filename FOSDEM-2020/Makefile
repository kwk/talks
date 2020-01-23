# It's necessary to set this because some environments don't link sh -> bash.
SHELL := /bin/bash
CUR_DIR := $(shell pwd)

all: presentation

.PHONY: clean
clean:
	rm -rf tmp

.PHONY: presentation
presentation: preprocess
	pandoc \
	  --from=markdown \
	  --to=beamer \
	  --filter pandoc-latex-fontsize \
	  --filter pandoc-latex-color \
	  --filter pandoc-beamer-block \
	  --filter ~/.cabal/bin/pandoc-emphasize-code \
	  --highlight-style highlight/my.theme \
	  --standalone \
	  --output=index.pdf \
	  --pdf-engine=pdflatex \
	  --slide-level 2\
	  theme-config.yaml tmp/index.md

# see file:///home/kkleine/Downloads/pp/pp-linux-x86_64/pp.html
.PHONY: preprocess
preprocess:
	mkdir -p tmp
	pp -img=tmp/ index.md > tmp/index.md

# run this manually
.PHONY: setup
setup:
	pip install --user --quiet \
	  pandoc-latex-fontsize \
	  pandoc-latex-color \
	  pandoc-beamer-block \
	cabal new-update \
	cabal install pandoc-emphasize-code

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

