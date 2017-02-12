IMAGE = andrewjesaitis/hugo
BLOG_POST_LOCATION = ~/Dropbox/Notes/content

docker-build:
	docker build --tag=$(IMAGE) .

commit-public:
	cd hugo/public && \
	git pull && \
	git add -A && \
	git commit -m "rebuilding site `date`" && \
	git push origin master

update-subrepos:
	git add hugo/public hugo/themes
	git commit -m "Update subrepos"
	git push

sync-dropbox:
	rsync -a --update --delete hugo/content ~/Dropbox/Notes/content

generate: docker-build
	rsync -a --update --delete $(BLOG_POST_LOCATION) $(shell pwd)/hugo/
	docker run --rm -it -v $(shell pwd)/hugo:/blog $(IMAGE) -s /blog

server: generate
	docker run --rm -it -p 1313:1313 --name hugo -v $(shell pwd)/hugo:/blog $(IMAGE) server --watch --bind='0.0.0.0'  -s /blog

deploy: generate commit-public update-subrepos

.PHONY: docker-build server generate deploy commit-public update-subrepos sync-dropbox
