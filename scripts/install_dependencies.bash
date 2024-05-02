#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

### Used env vars set by default in GitHub Actions
# docs: https://docs.github.com/en/actions/learn-github-actions/variables#default-environment-variables
# GITHUB_ACTIONS
# RUNNER_OS

if [ -z "$GITHUB_ACTIONS" ]; then
  printf "%s\n" "GITHUB_ACTIONS is not set. This script is only intended to be run in GitHub Actions. Exiting."
  exit 1
fi

if [ -z "$RUNNER_OS" ]; then
  printf "%s\n" "RUNNER_OS is not set. This script is only intended to be run in GitHub Actions. Exiting."
  exit 1
fi

### Set variables for tracking versions
# Elvish
elvish_semver="v0.19.2"
# Fish
fish_semver="3.7.0"
fish_apt_semver="${fish_semver}-1~jammy"
# Nushell
nushell_semver="0.86.0"
# Powershell
powershell_semver="7.3.3"
powershell_apt_semver="${powershell_semver}-1.deb"

### Install dependencies on Linux
if [ "$RUNNER_OS" = "Linux" ]; then
  printf "%s\n" "Installing dependencies on Linux"

  curl -fsSLo- https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc >/dev/null
  sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-bullseye-prod bullseye main" > /etc/apt/sources.list.d/microsoft.list'
  sudo add-apt-repository -y ppa:fish-shell/release-3
  sudo apt-get update
  sudo apt-get -y install curl parallel \
    fish="${fish_apt_semver}" \
    powershell="${powershell_apt_semver}"

  # Create $HOME/bin
  mkdir -p "$HOME/bin"

  # Download elvish binary and add to path
  curl https://dl.elv.sh/linux-amd64/elvish-${elvish_semver}.tar.gz -o elvish-${elvish_semver}.tar.gz
  tar xzf elvish-${elvish_semver}.tar.gz
  rm elvish-${elvish_semver}.tar.gz
  mv elvish-${elvish_semver} "$HOME/bin/elvish"

  # Download nushell binary and add to path
  curl -L https://github.com/nushell/nushell/releases/download/${nushell_semver}/nu-${nushell_semver}-x86_64-unknown-linux-gnu.tar.gz -o nu-${nushell_semver}-x86_64-unknown-linux-gnu.tar.gz
  tar xzf nu-${nushell_semver}-x86_64-unknown-linux-gnu.tar.gz
  rm nu-${nushell_semver}-x86_64-unknown-linux-gnu.tar.gz
  mv nu-${nushell_semver}-x86_64-unknown-linux-gnu/* "$HOME/bin"

  # Add $HOME/bin to path (add Elvish & Nushell to path)
  echo "$HOME/bin" >>"$GITHUB_PATH"
fi

### Install dependencies on macOS
if [ "$RUNNER_OS" = "macOS" ]; then
  printf "%s\n" "Installing dependencies on macOS"
  brew install coreutils parallel \
    elvish \
    fish \
    nushell \
    powershell
fi

### Install bats-core
printf "%s\n" "Installing bats-core"
bats_version=$(grep -Eo "^\\s*bats\\s*.*$" ".tool-versions" | cut -d ' ' -f2-)
git clone --depth 1 --branch "v$bats_version" https://github.com/bats-core/bats-core.git "$HOME/bats-core"
echo "$HOME/bats-core/bin" >>"$GITHUB_PATH"
