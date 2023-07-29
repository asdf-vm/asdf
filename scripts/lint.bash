#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

print.info() {
  printf '[INFO] %s\n' "$*"
}

print.error() {
  printf '[ERROR] %s\n' "$*" >&2
}

usage() {
  printf "%s\n" "Lint script for the asdf codebase. Must be executed from the"
  printf "%s\n\n" "repository root directory."
  printf "%s\n\n" "Usage: scripts/lint.bash [options]"
  printf "%s\n" "Options:"
  printf "%s\n" "  -c, --check   Error if any issues are found"
  printf "%s\n" "  -f, --fix     Automatically fix issues if possible"
  printf "%s\n" "  -h, --help    Display this help message"
}

run_shfmt_stylecheck() {
  local shfmt_flag=""
  if [ "$1" = "fix" ]; then
    shfmt_flag="--write"
  else
    shfmt_flag="--diff"
  fi

  print.info "Checking .bash with shfmt"
  shfmt --language-dialect bash --indent 2 "${shfmt_flag}" \
    completions/*.bash \
    bin/asdf \
    bin/private/asdf-exec \
    lib/utils.bash \
    lib/commands/*.bash \
    lib/functions/*.bash \
    scripts/*.bash \
    test/test_helpers.bash \
    test/fixtures/dummy_broken_plugin/bin/* \
    test/fixtures/dummy_legacy_plugin/bin/* \
    test/fixtures/dummy_plugin/bin/*

  print.info "Checking .bats with shfmt"
  shfmt --language-dialect bats --indent 2 "${shfmt_flag}" \
    test/*.bats
}

run_shellcheck_linter() {
  print.info "Checking .sh files with Shellcheck"
  shellcheck --shell sh --external-sources \
    asdf.sh

  print.info "Checking .bash files with Shellcheck"
  shellcheck --shell bash --external-sources \
    completions/*.bash \
    bin/asdf \
    bin/private/asdf-exec \
    lib/utils.bash \
    lib/commands/*.bash \
    lib/functions/*.bash \
    scripts/*.bash \
    test/test_helpers.bash \
    test/fixtures/dummy_broken_plugin/bin/* \
    test/fixtures/dummy_legacy_plugin/bin/* \
    test/fixtures/dummy_plugin/bin/*

  print.info "Checking .bats files with Shellcheck"
  shellcheck --shell bats --external-source \
    test/*.bats
}

run_custom_python_stylecheck() {
  local github_actions=${GITHUB_ACTIONS:-}
  local flag=

  if [ "$1" = "fix" ]; then
    flag="--fix"
  fi

  if [ -n "$github_actions" ] && ! command -v python3 &>/dev/null; then
    # fail if CI and no python3
    print.error "Detected execution in GitHub Actions but python3 was not found. This is required during CI linting."
    exit 1
  fi

  if ! command -v python3 &>/dev/null; then
    # skip if local and no python3
    printf "%s\n" "[WARNING] python3 not found. Skipping Custom Python Script."
  else
    print.info "Checking files with Custom Python Script."
    "${0%/*}/checkstyle.py" "${flag}"
  fi

}

# TODO: there is no elvish linter/formatter yet
#       see https://github.com/elves/elvish/issues/1651
#run_elvish_linter() {
#  printf "%s\n" "[WARNING] elvish linter/formatter not found, skipping for now."
#}

run_fish_linter() {
  local github_actions=${GITHUB_ACTIONS:-}
  local flag=

  if [ "$1" = "fix" ]; then
    flag="--write"
  else
    flag="--check"
  fi

  if [ -n "$github_actions" ] && ! command -v fish_indent &>/dev/null; then
    # fail if CI and no fish_ident
    print.error "Detected execution in GitHub Actions but fish_indent was not found. This is required during CI linting."
    exit 1
  fi

  if ! command -v fish_indent &>/dev/null; then
    # skip if local and no fish_ident
    printf "%s\n" "[WARNING] fish_indent not found. Skipping .fish files."
  else
    print.info "Checking .fish files with fish_indent"
    fish_indent "${flag}" ./**/*.fish
  fi
}

# TODO: there is no nushell linter/formatter yet
#run_nushell_linter() {
#  printf "%s\n" "[WARNING] nushell linter/formatter not found, skipping for now."
#}

# TODO: select powershell linter/formatter & setup installation in CI
#run_powershell_linter() {
#  printf "%s\n" "[WARNING] powershell linter/formatter not found, skipping for now."
#}

{
  repo_dir=$(git rev-parse --show-toplevel)
  current_dir=$(pwd -P)
  if [ "$repo_dir" != "$current_dir" ]; then
    print.error "This scripts requires execution from the repository root directory."
    printf "\t%s\t%s\n" "Repo root dir:" "$repo_dir"
    printf "\t%s\t%s\n\n" "Current dir:" "$current_dir"
    exit 1
  fi
}

if [ $# -eq 0 ]; then
  print.error "At least one option required."
  printf "=%.0s" {1..60}
  printf "\n"
  usage
  exit 1
fi

mode=
case "$1" in
-h | --help)
  usage
  exit 0
  ;;
-c | --check)
  mode="check"
  ;;
-f | --fix)
  mode="fix"
  ;;
*)
  print.error "Invalid flag: $1"
  printf "=%.0s" {1..60}
  printf "\n"
  usage
  exit 1
  ;;
esac

printf "%s\"%s\"\n" "[INFO] Executing with mode: " "$mode"

run_shfmt_stylecheck "$mode"
run_custom_python_stylecheck "$mode"
run_shellcheck_linter "$mode"
run_fish_linter "$mode"
#run_elvish_linter "$mode"
#run_nushell_linter "$mode"
#run_powershell_linter "$mode"

print.info "Success!"
