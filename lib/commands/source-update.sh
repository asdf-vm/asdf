source_update_command() {
  local package_name=$1
  if [ "$package_name" = "--all" ]; then
    for dir in $(asdf_dir)/sources/*; do
      (cd "$dir" && git pull)
    done
  else
    local source_path=$(get_source_path $package_name)
    check_if_source_exists $source_path
    (cd $source_path; git pull)
  fi
}
