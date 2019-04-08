#!/bin/bash

# Install dependencies needed for build on Travis CI

# Shellcheck is used by the linting script
# Fish is needed for the tests for asdf.fish

if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
  brew update;
  brew install shellcheck;

  brew update
  brew instal fish
elif [[ "$TRAVIS_OS_NAME" = "linux" ]]; then
  ${FISH_PPA:="nightly-master"}
  PPA="ppa:fish-shell/$FISH_PPA"

  sudo add-apt-repository -y "$PPA"
  sudo apt-get update
  sudo apt-get -y install fish
fi
