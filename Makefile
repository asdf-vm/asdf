MAIN_PACKAGE_PATH := ./cmd/asdf
TARGET_DIR := .
TARGET := asdf

# Currently this Makefile isn't used as part of the actual release binary build,
# It sets FULL_VERSION to a correct dev version including the SHA of the current
# commit. This Makefile could be used to generate nightly release binaries.

# Set base version for dev build from previous tag
BASE_VERSION = $(shell git describe --tags --abbrev=0 2>/dev/null || echo "0.1.0")

# Get number of commits since the last tag so that it can be used to generate valid higher semver
COMMITS_SINCE_TAG = $(shell git rev-list $(BASE_VERSION).. --count 2>/dev/null || echo "0")

# Get the current commit hash (short); add hash as semver build label which is not used for version sorting precedence
GIT_HASH = $(shell git rev-parse --short HEAD)

# Determine final version:
ifeq ($(COMMITS_SINCE_TAG),0)
    # If exactly on a tag, use BASE_VERSION as-is
    FULL_VERSION = "$(BASE_VERSION)"
else
    # Extract major, minor, patch components needed to generate final dev build version
    MAJOR = $(shell echo $(BASE_VERSION) | awk -F. '{print $$1}')
    MINOR = $(shell echo $(BASE_VERSION) | awk -F. '{print $$2}')
    PATCH = $(shell echo $(BASE_VERSION) | awk -F. '{print $$3}')

    # Increment patch version for dev builds so that dev build version is always > than last tag version
    DEV_PATCH = $(shell echo $$(($(PATCH) + 1)))

    # Construct full version for dev build
    FULL_VERSION = "$(MAJOR).$(MINOR).$(DEV_PATCH)-dev.$(COMMITS_SINCE_TAG)+$(GIT_HASH)"
endif

# Linker flags
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
