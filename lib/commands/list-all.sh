list_all_command() {
  local plugin_name=$1
  local plugin_path=$(get_plugin_path $plugin_name)
  check_if_plugin_exists $plugin_path

  local versions=$(bash ${plugin_path}/bin/list-all)

  IFS=' ' read -a versions_list <<< "$versions"

  sorted_versions=$(for version in ${versions_list[@]}; do echo $version; done | sort -r)

  for version in "${sorted_versions[@]}"
  do
    echo "${version}"
  done
}
