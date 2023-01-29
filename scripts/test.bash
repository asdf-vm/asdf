#!/usr/bin/env bash

set -euo pipefail

bats_options=(--timing --print-output-on-failure)

if command -v parallel; then
  # enable parallel jobs
  bats_options=("${bats_options[@]}" --jobs 2 --no-parallelize-within-files)
elif [[ -n "${CI-}" ]]; then
  printf "%s\n" "GNU parallel should be installed in the CI environment. Please install and rerun the test suite."
  exit 1
else
  printf "%s\n" "For faster test execution, install GNU parallel."
fi

bats "${bats_options[@]}" \
  ./test
