NAME=monorepo-diff-buildkite-plugin

HAS_DOCKER=$(shell command -v docker;)
HAS_GORELEASER=$(shell command -v goreleaser;)

.PHONY: all
all: quality test

.PHONY: test-go
test-go:
	go test -race -coverprofile=coverage.out -covermode=atomic

.PHONY: build-docker-test
build-docker-test:
ifneq (${HAS_DOCKER},)
	docker build -t ${NAME}-test .
else
	$(warning Docker not available; skipping Docker build for tests)
endif

.PHONY: test-docker
test-docker: build-docker-test
ifneq (${HAS_DOCKER},)
	docker run --rm ${NAME}-test go test -race -coverprofile=coverage.out -covermode=atomic
else
	$(warning Docker not available; skipping Docker test)
endif

.PHONY: test
test: test-go test-docker

.PHONY: quality
quality:
	go vet
	go fmt
	go mod tidy
ifneq (${HAS_DOCKER},)
	docker run --rm ${NAME}-lint go vet ./...
else
	$(warning Docker not available; skipping Docker linting)
endif

.PHONY: build
build:
ifneq (${HAS_GORELEASER},)
	goreleaser build --clean --skip-validate
else
	$(error goreleaser binary is missing, please install goreleaser)
endif

.PHONY: local
local:
	rm -f ${NAME}
	go build -o ${NAME}
	chmod +x ${NAME}
