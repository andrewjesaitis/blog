FROM jfloff/alpine-python:2.7-slim

MAINTAINER Andrew Jesaitis

RUN pip install pygments

RUN apk --update add curl tar 
RUN curl -L https://github.com/spf13/hugo/releases/download/v0.18.1/hugo_0.18.1_Linux-64bit.tar.gz | tar xvz
RUN apk del curl tar
RUN mv /hugo_0.18.1_linux_amd64/hugo_0.18.1_linux_amd64 /bin/hugo
RUN rm -fr /hugo_0.18.1_linux_amd64bi
RUN rm -rf /var/cache/apk/*

EXPOSE 1313

ENTRYPOINT ["/bin/hugo"]
