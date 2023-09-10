#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

print.info() {
  printf '[INFO] %s\n' "$1"
}

print.error() {
  printf '[ERROR] %s\n' "$1" >&2
}

{
  repo_dir=$(git rev-parse --show-toplevel)
  current_dir=$(pwd -P)
  if [ "$repo_dir" != "$current_dir" ]; then
    print.error "This scripts requires execution from the repository root directory."
    printf "\t%s\t%s\n" "Repo root dir:" "$repo_dir"
    printf "\t%s\t%s\n\n" "Current dir:" "$current_dir"
    exit 1
  fi
}

test_directory="./test"
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

print.info "Running Bats in directory '${test_directory}' with options:" "${bats_options[@]}"
bats "${bats_options[@]}" "${test_directory}"
