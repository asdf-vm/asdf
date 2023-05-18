# -*- sh -*-

plugin_remove_command() {
  local plugin_name=$1
  check_if_plugin_exists "$plugin_name"

  local plugin_path
  plugin_path=$(get_plugin_path "$plugin_name")

  asdf_run_hook "pre_asdf_plugin_remove" "$plugin_name"
  asdf_run_hook "pre_asdf_plugin_remove_${plugin_name}"

  if [ -f "${plugin_path}/bin/pre-plugin-remove" ]; then
    (
      export ASDF_PLUGIN_PATH=$plugin_path
      "${plugin_path}/bin/pre-plugin-remove"
    )
  fi

  rm -rf "$plugin_path"
  rm -rf "$(asdf_data_dir)/installs/${plugin_name}"
  rm -rf "$(asdf_data_dir)/downloads/${plugin_name}"

  for f in "$(asdf_data_dir)"/shims/*; do
    if [ -f "$f" ]; then # nullglob may not be set
      if grep -q "asdf-plugin: ${plugin_name}" "$f"; then
        rm -f "$f"
      fi
    fi
  done

  asdf_run_hook "post_asdf_plugin_remove" "$plugin_name"
  asdf_run_hook "post_asdf_plugin_remove_${plugin_name}"
}

plugin_remove_command "$@"
