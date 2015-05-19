list_command() {
  local package_name=$1
  local plugin_path=$(get_plugin_path $package_name)
  check_if_plugin_exists $plugin_path

  local package_installs_path=$(asdf_dir)/installs/${package_name}

  if [ -d $package_installs_path ]; then
    #TODO check if dir is empty and show no-installed-versions msg
    for install in ${package_installs_path}/*/; do
      echo "$(basename $install)"
    done
  else
    echo 'Oohes nooes ~! No versions installed'
  fi
}
