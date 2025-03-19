GO=CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go
BIN=pingdom-exporter
REPO=jusbrasil
IMAGE=$(REPO)/$(BIN)
DOCKER_BIN=docker
IMAGE_EXTRA_ARGS?=

VERSION=$(shell git describe --tags)

.PHONY: build
build:
	go mod tidy
	$(GO) build -a --ldflags "-X main.VERSION=$(VERSION) -w -extldflags '-static'" -tags netgo -o bin/$(BIN) ./cmd/$(BIN)

clean:
	rm -rf bin/

.PHONY: test
test:
	go vet ./...
	go test -coverprofile=coverage.out ./...
	go tool cover -func=coverage.out

.PHONY: lint
lint:
	go get -u golang.org/x/lint/golint
	golint ./...

# Build the Docker build stage TARGET
.PHONY: image
image:
	$(DOCKER_BIN) build -t $(IMAGE):$(VERSION) --build-arg=VERSION=${VERSION} $(IMAGE_EXTRA_ARGS) .

# Push Docker images to the registry
.PHONY: publish
publish:
	$(DOCKER_BIN) push $(IMAGE):$(VERSION)
	$(DOCKER_BIN) tag $(IMAGE):$(VERSION) $(IMAGE):latest
	$(DOCKER_BIN) push $(IMAGE):latest
