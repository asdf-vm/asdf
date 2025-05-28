#!/usr/bin/env bash

set -euo pipefail

print.info() {
  printf '[INFO] %s\n' "$1"
}

print.error() {
  printf '[ERROR] %s\n' "$1" >&2
}

BASE_DIR="$(git rev-parse --show-toplevel)"
readonly BASE_DIR
export BASE_DIR

current_dir="$(pwd -P)"
readonly current_dir

if [[ $BASE_DIR != "$current_dir" ]]; then
  print.error "This script requires execution from the repository root directory."
  printf "\t%s\t%s\n" "asdf repo root dir:" "$BASE_DIR" >&2
  printf "\t%s\t%s\n\n" "current dir:" "$current_dir" >&2
  exit 1
fi

readonly test_directory="$BASE_DIR/test"
bats_options=(--timing --print-output-on-failure)

if command -v parallel >/dev/null; then
  # Enable parallel jobs
  bats_options+=(--jobs 2 --no-parallelize-within-files)
elif [[ -n "${CI-}" ]]; then
  print.error "GNU parallel should be installed in the CI environment. Please install and rerun the test suite."
  exit 1
else
  print.info "For faster test execution, install GNU parallel."
fi

print.info "Running Bats in directory '${test_directory}' with options: '${bats_options[*]}'"
bats "${bats_options[@]}" "${test_directory}"
