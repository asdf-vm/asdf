list_all_command() {
  local package_name=$1
  local source_path=$(get_source_path $package_name)
  check_if_source_exists $source_path
  local versions=$( ${source_path}/bin/list-all )

  IFS=' ' read -a versions_list <<< "$versions"

  for version in "${versions_list[@]}"
  do
    echo "${version}"
  done
}
