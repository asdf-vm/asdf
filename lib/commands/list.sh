list_command() {
  local plugin_name=$1
  local plugin_path=$(get_plugin_path $plugin_name)
  check_if_plugin_exists $plugin_path

  local plugin_installs_path=$(asdf_dir)/installs/${plugin_name}

  if [ -d $plugin_installs_path ]; then
    #TODO check if dir is empty and show no-installed-versions msg
    for install in ${plugin_installs_path}/*/; do
      echo "$(basename $install)"
    done
  else
    echo 'Oohes nooes ~! No versions installed'
  fi
}
