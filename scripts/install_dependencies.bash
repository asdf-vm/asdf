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

### Set environment variables for tracking versions
# Elvish
ELVISH_SEMVER="v0.19.2"
# Fish
FISH_SEMVER="3.6.1"
FISH_APT_SEMVER="${FISH_SEMVER}-1~jammy"
# Nushell
NUSHELL_SEMVER="0.78.0"
# Powershell
POWERSHELL_SEMVER="7.3.3"
POWERSHELL_APT_SEMVER="${POWERSHELL_SEMVER}-1.deb"

### Install dependencies on Linux
if [ "$RUNNER_OS" = "Linux" ]; then
  printf "%s\n" "Installing dependencies on Linux"

  curl -fsSLo- https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc >/dev/null
  sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-bullseye-prod bullseye main" > /etc/apt/sources.list.d/microsoft.list'
  sudo add-apt-repository -y ppa:fish-shell/release-3
  sudo apt-get update
  sudo apt-get -y install curl parallel \
    fish="${FISH_APT_SEMVER}" \
    powershell="${POWERSHELL_APT_SEMVER}"

  # Create $HOME/bin
  mkdir -p "$HOME/bin"

  # Download elvish binary and add to path
  curl https://dl.elv.sh/linux-amd64/elvish-${ELVISH_SEMVER}.tar.gz -o elvish-${ELVISH_SEMVER}.tar.gz
  tar xzf elvish-${ELVISH_SEMVER}.tar.gz
  rm elvish-${ELVISH_SEMVER}.tar.gz
  mv elvish-${ELVISH_SEMVER} "$HOME/bin/elvish"

  # Download nushell binary and add to path
  curl -L https://github.com/nushell/nushell/releases/download/${NUSHELL_SEMVER}/nu-${NUSHELL_SEMVER}-x86_64-unknown-linux-gnu.tar.gz -o nu-${NUSHELL_SEMVER}-x86_64-unknown-linux-gnu.tar.gz
  tar xzf nu-${NUSHELL_SEMVER}-x86_64-unknown-linux-gnu.tar.gz
  rm nu-${NUSHELL_SEMVER}-x86_64-unknown-linux-gnu.tar.gz
  mv nu-${NUSHELL_SEMVER}-x86_64-unknown-linux-gnu/* "$HOME/bin"

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
git clone --depth 1 --branch "v$(grep -Eo "^\\s*bats\\s*.*$" ".tool-versions" | cut -d ' ' -f2-)" https://github.com/bats-core/bats-core.git "$HOME/bats-core"
echo "$HOME/bats-core/bin" >>"$GITHUB_PATH"
