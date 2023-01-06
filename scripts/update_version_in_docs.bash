#!/usr/bin/env bash

set -euo pipefail

version=$(cat version.txt)
sed -i "s/\(git clone.*--branch \).*\(\`.*|\)/\1v$version\2/" docs/guide/getting-started.md
