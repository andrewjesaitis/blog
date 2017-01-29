BRANCH = $(shell git rev-parse --symbolic-full-name --abbrev-ref HEAD | sed -e 's/[^A-Za-z0-9_.-]/-/g')
GITHASH = $(shell git rev-parse --short HEAD)
PROJECT = blog
IMAGE = $(USER)/$(PROJECT)
RELEASE = $(PROJECT)-$(BRANCH)-$(GITHASH)
BLOG_POST_LOCATION = ~/Dropbox/Notes/blog
HUGO_THEME ?= hugo-uno
FORWARDED_PORT ?= 0.0.0.0:1313:1313


docker-build:
	docker build --tag=$(IMAGE) .

shell: docker-build
	docker run --rm -it -p $(FORWARDED_PORT) -v $(shell pwd):/opt/$(PROJECT) $(IMAGE) /bin/bash

generate: docker-build
	# Find and remove all existing files except the .keep
	find $(shell pwd)/hugo/content/post -type f -not -path '*/\.*' -execdir rm {} \;
	cp -r $(BLOG_POST_LOCATION)/* $(shell pwd)/hugo/content/post
	# Update posts to remove smart quotes
	find $(shell pwd)/hugo/content/post -type f -execdir sed -i "" s/[”“]/'"'/g {} \;

server: generate
	echo "Starting hugo server. Connect at `docker-machine ip dev`"
	docker run --rm -it -p $(FORWARDED_PORT) -v $(shell pwd):/opt/$(PROJECT) -e PROJECT=$(PROJECT) $(IMAGE) /bin/bash start.sh

build: docker-build

# push to google cloud storage with version tag and creds
# push: build

.PHONY: docker-build shell server generate build push
