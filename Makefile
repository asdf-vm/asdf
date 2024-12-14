MAIN_PACKAGE_PATH := ./cmd/asdf
TARGET_DIR := .
TARGET := asdf
FULL_VERSION = $(shell ./scripts/asdf-version )
LINKER_FLAGS = '-s -X main.version=${FULL_VERSION}'

# Not sure what the default location should be for builds
build: # test lint
	go build -ldflags=${LINKER_FLAGS} -o=${TARGET_DIR}/${TARGET} ${MAIN_PACKAGE_PATH}

fmt:
	go fmt ./...
	gofumpt -l -w .

verify:
	go mod verify

tidy:
	go mod tidy -v

audit: verify vet test

test:
	go test -coverprofile=/tmp/coverage.out  -bench= -race ./...

cover: test
	go tool cover -html=/tmp/coverage.out

lint: fmt
	staticcheck -tests -show-ignored ./...
	revive -set_exit_status ./...

vet: fmt
	go vet ./...

run: build
	${TARGET_DIR}/${TARGET}

.PHONY: fmt lint vet build test run
