plugin_add_command() {
  local package_name=$1
  local source_url=$2
  local plugin_path=$(get_plugin_path $package_name)

  mkdir -p $(asdf_dir)/sources
  git clone $source_url $plugin_path
  if [ $? -eq 0 ]; then
    chmod +x $plugin_path/bin/*
  fi
}
