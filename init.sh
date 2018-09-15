#!/usr/bin/env bash

export ASDF_DIR
export ASDF_DATA_DIR

ASDF_DIR="$(dirname "$current_script_path")"
ASDF_DATA_DIR="${ASDF_DATA_DIR:-$HOME/.asdf}"

[ -d "$ASDF_DIR" ] || echo '$ASDF_DIR is not a directory'
