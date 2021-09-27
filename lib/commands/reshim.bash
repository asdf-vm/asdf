remove_shim_for_version() {
  local plugin_name=$1
  local version=$2
  local shim_name

  shim_name=$(basename "$3")

  local shim_path
  shim_path="$(asdf_data_dir)/shims/$shim_name"

  local count_installed
  count_installed=$(list_installed_versions "$plugin_name" | wc -l)

  if ! grep -x "# asdf-plugin: $plugin_name $version" "$shim_path" >/dev/null 2>&1; then
    return 0
  fi

  sed -i.bak -e "/# asdf-plugin: $plugin_name $version"'$/d' "$shim_path"
  rm "$shim_path".bak

  if ! grep "# asdf-plugin:" "$shim_path" >/dev/null ||
    [ "$count_installed" -eq 0 ]; then
    rm -f "$shim_path"
  fi
}
