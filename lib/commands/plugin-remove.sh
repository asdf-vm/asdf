set -o nounset -o pipefail -o errexit
IFS=$'\t\n' # Stricter IFS settings

plugin_remove_command() {
  local plugin_name=${1:-}
  check_if_plugin_exists "$plugin_name"

  local plugin_path
  plugin_path=$(get_plugin_path "$plugin_name")

  rm -rf "$plugin_path"
  rm -rf "$(asdf_data_dir)/installs/${plugin_name}"

  # This command may fail if no shims are found
  grep -l "asdf-plugin: ${plugin_name}" "$(asdf_data_dir)"/shims/* 2>/dev/null | xargs rm -f || true
}
