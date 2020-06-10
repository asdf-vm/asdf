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

printf "asdf setup"
printf "1: install asdf - completed!"
printf "2: add asdf to your shell - https://asdf-vm.com/#/core-manage-asdf-vm"
printf "3: add a plugin - https://asdf-vm.com/#/core-manage-plugins"
printf "4: install a tool version - https://asdf-vm.com/#/core-manage-versions"
