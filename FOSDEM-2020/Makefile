# It's necessary to set this because some environments don't link sh -> bash.
SHELL := /usr/bin/bash
CUR_DIR := $(shell pwd)

all: presentation

.PHONY: clean
clean:
	rm -rf tmp

.PHONY: presentation
presentation: 
	/usr/bin/pandoc \
	  --from=markdown \
	  --to=beamer \
	  --filter pandoc-latex-fontsize \
	  --filter pandoc-latex-color \
	  --filter pandoc-beamer-block \
	  --highlight-style highlight/my.theme \
	  --standalone \
	  --output=index.pdf \
	  --pdf-engine=xelatex \
	  --slide-level 2\
	  theme-config.yaml index.md

# see file:///home/kkleine/Downloads/pp/pp-linux-x86_64/pp.html
.PHONY: preprocess
preprocess:
	-mkdir -p tmp
	pp -img=tmp/ index.md > tmp/index.md

# run this manually
.PHONY: setup
setup:
	pip install --user --quiet \
	  pandoc-latex-fontsize \
	  pandoc-latex-color \
	  pandoc-beamer-block \

# Call either "make image-with-podman" or "make image-with-docker"
image-with-%: Dockerfile
	$(eval tool:=$(subst image-with-,,$@))
	$(tool) build --network host . -t talks/fosdem2020

# Call either "make presentation-with-podman" or "make presentation-with-docker"
# presentation-with-%:
# 	$(tool) run \
# 	  -it \
# 	  --rm \
# 	  -v $(CUR_DIR):/home/presenter/talk:Z \
# 	  -u $(shell id -u $(USER)):$(shell id -g $(USER)) \
# 	  talks/fosdem2020

# Call either "make presentation-with-podman" or "make presentation-with-docker"
presentation-with-podman:
	$(tool) run \
	  -it \
	  --rm \
	  -v $(CUR_DIR):/home/presenter/talk:Z \
	  --userns=keep-id \
	  talks/fosdem2020

	  