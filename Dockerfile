FROM jfloff/alpine-python:3.7-slim

MAINTAINER Andrew Jesaitis

RUN pip install pygments

RUN apk --update add curl tar 
RUN curl -L https://github.com/spf13/hugo/releases/download/v0.55.6/hugo_0.55.6_Linux-64bit.tar.gz | tar xvz
RUN apk del curl tar
RUN mv /hugo /bin/hugo
RUN rm -rf /var/cache/apk/*

EXPOSE 1313

ENTRYPOINT ["/bin/hugo"]
