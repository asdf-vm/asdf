#!/usr/bin/env bash

# Unoffical Bash "strict mode"
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
#ORIGINAL_IFS=$IFS
IFS=$'\t\n' # Stricter IFS settings

asdf_install_dir=${ASDF_INSTALL_DIR:-"$HOME/.asdf"}

git clone https://github.com/asdf-vm/asdf.git "${asdf_install_dir}"
# checkout latest tag in repo in another dir
# credit: https://stackoverflow.com/a/6073628/7911479 and https://stackoverflow.com/a/31811385/7911479
git --git-dir "${asdf_install_dir}/.git" --work-tree "${asdf_install_dir}" checkout "$(git describe --abbrev=0 --tags)" --quiet

printf "\n%s\n" "asdf setup"
printf "%s\t\t\t%s\n" "1: install asdf" "completed!"
printf "%s\t%s\n" "2: add asdf to your shell" "https://asdf-vm.com/#/core-manage-asdf-vm"
printf "%s\t\t\t%s\n" "3: add a plugin" "https://asdf-vm.com/#/core-manage-plugins"
printf "%s\t%s\n" "4: install a tool version" "https://asdf-vm.com/#/core-manage-versions"
