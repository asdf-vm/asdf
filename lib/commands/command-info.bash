# -*- sh -*-
# shellcheck source=lib/functions/plugins.bash
. "$(dirname "$(dirname "$0")")/lib/functions/plugins.bash"

info_command() {
  printf "%s:\\n%s\\n\\n" "OS" "$(uname -a)"
  printf "%s:\\n%s\\n\\n" "SHELL" "$($SHELL --version)"
  printf "%s:\\n%s\\n\\n" "ASDF VERSION" "$(asdf_version)"
  printf "%s:\\n%s\\n\\n" "ASDF ENVIRONMENT VARIABLES" "$(env | grep -E "ASDF_DIR|ASDF_DATA_DIR|ASDF_CONFIG_FILE|ASDF_DEFAULT_TOOL_VERSIONS_FILENAME")"
  printf "%s:\\n%s\\n\\n" "ASDF INSTALLED PLUGINS" "$(plugin_list_command --urls --refs)"
}

info_command "$@"
