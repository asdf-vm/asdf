version_command() {
  local cmd=$1

  if [ $# -gt 3 ]; then
    echo usage: $cmd [PLUGIN] [VERSION]
    exit 1
  fi

  local file
  if [ $cmd = "global" ]; then
    file=$HOME/.tool-versions
  else
    file=$(get_asdf_versions_file_path)
    if [ -z "$file" ]; then
      file=.tool-versions
    fi
  fi

  if [ $# -ne 3 -a ! -f $file ]; then
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
    result=$(get_tool_version_from_file $file $plugin)
    if [ -n "$result" ]; then
      echo $result
      exit 0
    else
      echo "version not set for $plugin"
      exit 1
    fi
  fi

  local version=$3

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
