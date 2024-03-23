MAIN_PACKAGE_PATH := .
TARGET_DIR := .
TARGET := asdf

# Not sure what the default location should be for builds
build: test lint
	go build -o=${TARGET_DIR}/${TARGET} ${MAIN_PACKAGE_PATH}

fmt:
	go fmt ./...

verify:
	go mod verify

tidy:
	go mod tidy -v

audit: verify vet test

test:
	go test -coverprofile=/tmp/coverage.out  -bench= -v -race ./...

cover: test
	go tool cover -html=/tmp/coverage.out

lint: fmt
	staticcheck -tests -show-ignored ./...
	revive ./...

vet: fmt
	go vet .

run: build
	${TARGET_DIR}/${TARGET}

.PHONY: fmt lint vet build test run
