MAIN_PACKAGE_PATH := ./cmd/asdf
TARGET_DIR := .
TARGET := asdf

# Because this Makefile isn't used as part of the actual release binary build,
# It sets FULL_VERSION to a dev version containing the SHA of the current
# commit. If we ever use this Makefile to generate release binaries this code
# will need to change.
FULL_VERSION = "$(shell git rev-parse --short HEAD)-dev"
LINKER_FLAGS = '-s -X main.version=${FULL_VERSION}'

# Not sure what the default location should be for builds
build: # test lint
	go build -ldflags=${LINKER_FLAGS} -o=${TARGET_DIR}/${TARGET} ${MAIN_PACKAGE_PATH}

fmt:
	go fmt ./...
	go run mvdan.cc/gofumpt -l -w .

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
	go run honnef.co/go/tools/cmd/staticcheck -tests -show-ignored ./...
	go run github.com/mgechev/revive -set_exit_status ./...

vet: fmt
	go vet ./...

run: build
	${TARGET_DIR}/${TARGET}

.PHONY: fmt lint vet build test run
