current_version() {
  local plugin_name=$1

  check_if_plugin_exists "$plugin_name"

  local search_path
  local version_and_path
  local version

  search_path=$(pwd)
  version_and_path=$(find_version "$plugin_name" "$search_path")
  version=$(cut -d '|' -f 1 <<< "$version_and_path");

  check_if_version_exists "$plugin_name" "$version"
  check_for_deprecated_plugin "$plugin_name"

  if [ -z "$version" ]; then
    echo "No version set for $plugin_name"
    exit 1
  else
    echo "$version"
    exit 0
  fi
}

which_command() {
  local bin_name=$1
  local shim_path
  local plugin_name
  local plugin_versions_and_paths
  local plugin_versions

  shim_path="$(asdf_dir)/shims/$bin_name"

  if [ ! -f "$shim_path" ]; then
    echo "no shim found for $bin_name"
    exit 1
  fi

  plugin_name="$(sed -ne 's/# asdf-plugin: \(.*\)/\1/p' "$shim_path")"

  if [ -z "$plugin_name" ]; then
    if soft_check_if_plugin_exists "$bin_name"; then
      plugin_name="$bin_name"
    else
      echo "could not determine plugin for $bin_name"
      exit 1
    fi
  fi

  check_if_plugin_exists "$plugin_name"


  plugin_versions_and_paths=$(find_version "$plugin_name" "$(pwd)")
  IFS=' ' read -ra plugin_versions <<< "$(cut -d '|' -f 1 <<< "$plugin_versions_and_paths")"

  binary_versions=($(sed -ne 's/# asdf-plugin-version: \(.*\)/\1/p' "$shim_path"))

  if [ "${#binary_versions[@]}" -eq 0 ]; then
    binary_versions=($plugin_versions)
  fi

  for plugin_version in "${plugin_versions[@]}"; do
    for binary_version in "${binary_versions[@]}"; do
      if [ "$plugin_version" = "$binary_version" ]; then
        echo "$(asdf_dir)/installs/$plugin_name/$plugin_version/bin/$bin_name"
        return 0
      fi
    done
  done

  echo "could not find installed version for $bin_name"
  exit 1
}

# Warn if the plugin isn't using the updated legacy file api.
check_for_deprecated_plugin() {
  local plugin_name=$1
  local plugin_path
  local legacy_config

  plugin_path=$(get_plugin_path "$plugin_name")
  legacy_config=$(get_asdf_config_value "legacy_version_file")
  local deprecated_script="${plugin_path}/bin/get-version-from-legacy-file"
  local new_script="${plugin_path}/bin/list-legacy-filenames"

  if [ "$legacy_config" = "yes" ] && [ -f "$deprecated_script" ] && [ ! -f "$new_script" ]; then
    echo "Heads up! It looks like your $plugin_name plugin is out of date. You can update it with:"
    echo ""
    echo "  asdf plugin-update $plugin_name"
    echo ""
  fi
}
