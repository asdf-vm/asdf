source_remove_command() {
  local package_name=$1
  local source_path=$(get_source_path $package_name)

  rm -rf $source_path
  rm -rf $(asdf_dir)/installs/${package_name}
}
