IMAGE = andrewjesaitis/hugo
BLOG_POST_LOCATION = ~/Dropbox/Notes/content

docker-build:
	docker build --tag=$(IMAGE) .

deploy-s3:
	cd hugo/public && \
	s3deploy -v -bucket andrewjesaitis-blog --public-access --distribution-id $(BLOG_CF_DIST_ID)

update-theme:
	git add hugo/themes
	git commit -m "Update subrepos"
	git push

sync-dropbox:
	rsync -a --update --delete ~/Dropbox/Notes/content ./hugo/
	rsync -a --update --delete ~/Dropbox/Notes/images ./hugo/static/

generate: docker-build sync-dropbox
	docker run --rm -it -v $(shell pwd)/hugo:/blog $(IMAGE) -s /blog

server: generate
	docker run --rm -it -p 1313:1313 --name hugo -v $(shell pwd)/hugo:/blog $(IMAGE) server --watch --bind='0.0.0.0'  -s /blog

deploy: generate deploy-s3

.PHONY: docker-build server generate deploy deploy-s3 update-theme sync-dropbox
