#!/usr/bin/env bash

set -euo pipefail

sed -i "s/\\(git clone.*--branch \\).*\\(\`.*|\\)/\\1v$(cat version.txt)\\2/" docs/guide/getting-started.md
