#!/usr/bin/env bash

set -euo pipefail

test_directory="test"
bats_options=(--timing --print-output-on-failure)

if command -v parallel >/dev/null; then
  # enable parallel jobs
  bats_options=("${bats_options[@]}" --jobs 2 --no-parallelize-within-files)
elif [[ -n "${CI-}" ]]; then
  printf "* %s\n" "GNU parallel should be installed in the CI environment. Please install and rerun the test suite."
  exit 1
else
  printf "* %s\n" "For faster test execution, install GNU parallel."
fi

printf "* %s\n" "Running Bats in directory '${test_directory}' with options:" "${bats_options[@]}"
bats "${bats_options[@]}" "${test_directory}"
