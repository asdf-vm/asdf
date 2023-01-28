#!/usr/bin/env bash

set -euo pipefail

bats \
  --timing \
  --jobs 16 \
  --no-parallelize-within-files \
  --print-output-on-failure \
  test
