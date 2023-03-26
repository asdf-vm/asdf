# -*- sh -*-
# shellcheck source=lib/functions/plugins.bash
. "$(dirname "$(dirname "$0")")/lib/functions/plugins.bash"

info_command() {
  printf "%s:\n%s\n\n" "OS" "$(uname -a)"
  printf "%s:\n%s\n\n" "SHELL" "$("$SHELL" --version)"
  printf "%s:\n%s\n\n" "BASH VERSION" "$BASH_VERSION"
  printf "%s:\n%s\n\n" "ASDF VERSION" "$(asdf_version)"
  printf '%s\n' 'ASDF INTERNAL VARIABLES:'
  printf 'ASDF_DEFAULT_TOOL_VERSIONS_FILENAME=%s\n' "${ASDF_DEFAULT_TOOL_VERSIONS_FILENAME}"
  printf 'ASDF_DATA_DIR=%s\n' "${ASDF_DATA_DIR}"
  printf 'ASDF_DIR=%s\n' "${ASDF_DIR}"
  printf 'ASDF_CONFIG_FILE=%s\n\n' "${ASDF_CONFIG_FILE}"
  printf "%s:\n%s\n\n" "ASDF INSTALLED PLUGINS" "$(plugin_list_command --urls --refs)"
}

info_command "$@"
