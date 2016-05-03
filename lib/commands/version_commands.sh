get_plugin_version() {
  local cmd=$1
  local file=$2
  local plugin=$3
  local legacy_version_file_support=$(get_asdf_config_value "legacy_version_file")
  local result

  if [ $cmd = "local" -a "$legacy_version_file_support" = "yes" -a \
            \( ! -f $file -o $file = "$HOME/.tool-versions" \) ]; then
      result=$(get_tool_version_from_legacy_file $plugin $(pwd))
      if [ -n "$result" ]; then
          echo $result
          exit 0
      fi
  fi

  if [ -f $file ]; then
    result=$(get_tool_version_from_file $file $plugin)
  fi

  if [ -n "$result" ]; then
    echo $result
    exit 0
  fi


  echo "version not set for $plugin"
  exit 1
}

version_command() {
  local cmd=$1

  local file
  if [ $cmd = "global" ]; then
    file=$HOME/.tool-versions
  else
    file=$(get_asdf_versions_file_path)
    if [ -z "$file" ]; then
      file=.tool-versions
    fi
  fi

  if [ $# -eq 1 -a ! -f $file ]; then
    echo $file does not exist
    exit 1
  fi

  if [ $# -eq 1 ]; then
    cat $file
    exit 0
  fi

  local plugin=$2

  check_if_plugin_exists $(get_plugin_path $plugin)

  if [ $# -eq 2 ]; then
    get_plugin_version $cmd $file $plugin
  fi

  local version=${@:3}

  check_if_version_exists $plugin $version

  if [ -f $file ] && grep $plugin $file > /dev/null; then
    sed -i -e "s/$plugin .*/$plugin $version/" $file
  else
    echo "$plugin $version" >> $file
  fi
}

local_command() {
  version_command "local" $@
}

global_command() {
  version_command "global" $@
}
