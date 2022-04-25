IMAGE = andrewjesaitis/hugo
BLOG_CONTENT_LOCATION = ~/Dropbox/Notes

snapshots:
	python3 snapshot_templater.py --template $(BLOG_CONTENT_LOCATION)/templates/snapshot.tmpl --directory $(BLOG_CONTENT_LOCATION)/images/snapshots/ --output $(BLOG_CONTENT_LOCATION)/content/snapshots/

docker-build:
	docker build --tag=$(IMAGE) .

deploy-s3:
	cd hugo/public && \
	s3deploy -v -bucket andrewjesaitis-blog --public-access --distribution-id $(BLOG_CF_DIST_ID)

update-theme:
	git add hugo/themes
	git commit -m "Update subrepos"
	git push

sync-files:
	rsync -a --update --delete ~/Dropbox/Notes/images ./hugo/static/
	rsync -a --update --delete ~/Dropbox/Notes/content ./hugo/

sync-drafts:
	rsync -a --update --delete ~/Dropbox/Notes/drafts/* ./hugo/content/post/

generate: docker-build sync-files
	docker run --rm -it -v $(shell pwd)/hugo:/blog $(IMAGE) -s /blog

server: sync-files
	docker run --rm -it -p 1313:1313 --name hugo -v $(shell pwd)/hugo:/blog $(IMAGE) server --watch --bind='0.0.0.0'  -s /blog

server-drafts: sync-files sync-drafts
	docker run --rm -it -p 1313:1313 --name hugo -v $(shell pwd)/hugo:/blog $(IMAGE) server --buildDrafts --watch --bind='0.0.0.0'  -s /blog

deploy: generate deploy-s3

.PHONY: docker-build server generate deploy deploy-s3 update-theme sync-files sync-drafts
