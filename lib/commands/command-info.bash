# -*- sh -*-
# shellcheck source=lib/functions/plugins.bash
. "$(dirname "$(dirname "$0")")/lib/functions/plugins.bash"

get_shell() {
  if [[ -z $FISH_VERSION ]]; then
    printf "fish, version %s" "$FISH_VERSION"
  elif [[ -z $ZSH_VERSION ]]; then
    printf "zsh, version %s" "$ZSH_VERSION"
  elif [[ -z $BASH_VERSION ]]; then
    printf "bash, version %s" "$BASH_VERSION"
  else
    $SHELL --version
  fi
}

info_command() {
  printf "%s:\\n%s\\n\\n" "OS" "$(uname -a)"
  printf "%s:\\n%s\\n\\n" "SHELL" "$(get_shell)"
  printf "%s:\\n%s\\n\\n" "ASDF VERSION" "$(asdf_version)"
  printf "%s:\\n%s\\n\\n" "ASDF ENVIRONMENT VARIABLES" "$(env | grep -E "ASDF_DIR|ASDF_DATA_DIR|ASDF_CONFIG_FILE|ASDF_DEFAULT_TOOL_VERSIONS_FILENAME")"
  printf "%s:\\n%s\\n\\n" "ASDF INSTALLED PLUGINS" "$(plugin_list_command --urls --refs)"
}

info_command "$@"
