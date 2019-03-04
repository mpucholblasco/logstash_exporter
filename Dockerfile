# See: https://hub.docker.com/_/golang/
FROM golang:latest as golang

# See: https://github.com/golang/dep/releases
ARG GODEP_VERSION=v0.5.0
ARG GOLINT_VERSION=v1.15.0

##
# We break up the monolithic command so the cacheability for each layer/step is better
##
# Download `dep` into /usr/local/bin/dep. Follow re-directs, and be as silent aspossible; output if errors
RUN curl --fail --silent --show-error --location --output /usr/local/bin/dep https://github.com/golang/dep/releases/download/${GODEP_VERSION}/dep-linux-amd64 && \
        chmod +x /usr/local/bin/dep

# Download the golang linter cli binary
# See: https://github.com/golangci/golangci-lint#ci-installation
RUN curl --silent --fail --location https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | sh -s -- -b $(go env GOPATH)/bin ${GOLINT_VERSION}

# Fetch the source
RUN go get -u github.com/sequra/logstash_exporter

# Fetch the source and dependencies
RUN cd $GOPATH/src/github.com/sequra/logstash_exporter && \
        dep init && \
        dep ensure

# Build!
RUN cd $GOPATH/src/github.com/sequra/logstash_exporter && \
        make

# It looks like the `latest` tag uses uclibc
# See: https://hub.docker.com/_/busybox/
FROM busybox:latest 
COPY --from=golang /go/src/github.com/sequra/logstash_exporter/logstash_exporter /
LABEL maintainer devops@sequra.es
EXPOSE 9198
ENTRYPOINT ["/logstash_exporter"]
