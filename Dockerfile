# See: https://hub.docker.com/_/golang/
FROM golang:latest as golang

# Fetch the source
RUN go get -u github.com/sequra/logstash_exporter

# Get dependencies and build!
RUN cd $GOPATH/src/github.com/sequra/logstash_exporter && \
        make

# It looks like the `latest` tag uses uclibc
# See: https://hub.docker.com/_/busybox/
FROM busybox:latest 
COPY --from=golang /go/src/github.com/sequra/logstash_exporter/logstash_exporter /
LABEL maintainer devops@sequra.es
EXPOSE 9198
ENTRYPOINT ["/logstash_exporter"]
