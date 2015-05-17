plugin_update_command() {
  local package_name=$1
  if [ "$package_name" = "--all" ]; then
    for dir in $(asdf_dir)/sources/*; do
      (cd "$dir" && git pull)
    done
  else
    local plugin_path=$(get_plugin_path $package_name)
    check_if_plugin_exists $plugin_path
    (cd $plugin_path; git pull)
  fi
}
