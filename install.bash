#!/usr/bin/env bash

# Unoffical Bash "strict mode"
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
#ORIGINAL_IFS=$IFS
IFS=$'\t\n' # Stricter IFS settings

asdf_install_dir=${ASDF_INSTALL_DIR:-"~/.asdf"}

git clone https://github.com/asdf-vm/asdf.git "${asdf_install_dir}"
# checkout latest tag
git --git-dir "${asdf_install_dir}" checkout "$(git --git-dir "${asdf_install_dir}" describe --abbrev=0 --tags)"

printf "[WARNING] asdf requires further configuration. See the documentation at https://asdf-vm.com/#/core-manage-asdf-vm"
