# -*- sh -*-

# shellcheck disable=SC2059
check_command() {
  local exit_status=0
  local not_installed_description
  not_installed_description="Not installed"

  while read -r line; do
    if [[ $line == *"$not_installed_description"* ]]; then
      exit_status=$((exit_status + 1))
    fi
  done <<<"$(asdf current 2>&1)"

  exit "$exit_status"
}

check_command
