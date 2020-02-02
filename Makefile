all: clean format golint

include Makefile.common

TARGET ?= logstash_exporter

GOLINT         := $(FIRST_GOPATH)/bin/golangci-lint
GOLINT_VERSION := v1.18.0

vendor:
	@echo ">> installing dependencies on vendor"
	GO111MODULE=$(GO111MODULE) $(GO) mod vendor

test:
	@echo ">> running tests"
	GO111MODULE=$(GO111MODULE) $(GO) test -short $(pkgs)

format:
	@echo ">> formatting code"
	GO111MODULE=$(GO111MODULE) $(GO) fmt $(pkgs)

golint: golangci-lint
	@echo ">> linting code"
	GO111MODULE=$(GO111MODULE) $(GOLINT) run

build: promu vendor
	@echo ">> building binaries"
	GO111MODULE=$(GO111MODULE) $(PROMU) build --prefix $(PREFIX)

crossbuild: promu vendor
	@echo ">> cross-building binaries"
	GO111MODULE=$(GO111MODULE) $(PROMU) crossbuild

tarball: promu vendor
	@echo ">> building release tarball"
	GO111MODULE=$(GO111MODULE) $(PROMU) tarball --prefix $(PREFIX) $(BIN_DIR)

tarballs: promu vendor
	@echo ">> building release tarballs"
	GO111MODULE=$(GO111MODULE) $(PROMU) crossbuild tarballs $(BIN_DIR)

clean:
	@echo ">> Cleaning up"
	@find . -type f -name '*~' -exec rm -fv {} \;
	@rm -fv $(TARGET)

.PHONY: all clean format golint build test

.PHONY: golangci-lint
golangci-lint: $(GOLINT)

$(GOLINT):
	curl --silent --fail --location https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | sh -s -- -b $(FIRST_GOPATH)/bin ${GOLINT_VERSION}
