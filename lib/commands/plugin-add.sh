plugin_add_command() {
  if [ "$#" -ne 2 ]; then
    display_error "usage: asdf plugin-add <name> <git-url>"
    exit 1
  fi

  local plugin_name=$1
  local source_url=$2
  local plugin_path=$(get_plugin_path $plugin_name)

  mkdir -p $(asdf_dir)/plugins

  if [ -d $plugin_path ]; then
    display_error "Plugin named $plugin_name already added"
    exit 1
  else
    git clone $source_url $plugin_path
    if [ $? -eq 0 ]; then
      chmod +x $plugin_path/bin/*
    else
      exit 1
    fi
  fi
}
