#!/usr/bin/env bash

set -euo pipefail

version_major_minor_x="$(cat version.txt | cut -f1-2 -d ".").x"

# skip if version is already in the list
if ! grep -q "$version_major_minor_x" SECURITY.md; then
  # append new version to top of list
  sed -i "s/white_check_mark:/x:               /g" SECURITY.md
  sed -i "s/^\\(| -* | -* |\\)$/\\1\\n| $version_major_minor_x  | :white_check_mark: |/" SECURITY.md
fi
