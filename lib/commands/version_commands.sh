version_command() {
  local cmd=$1
  local plugin=$2
  local version=$3
  local file

  if [ "$#" -ne 3 ]; then
    echo "Usage: asdf $cmd <name> <version>"
    exit 1
  fi

  if [ $cmd = "global" ]; then
    file=$HOME/.tool-versions
  else
    file=$(pwd)/.tool-versions
  fi

  check_if_plugin_exists $plugin
  check_if_version_exists $plugin $version

  if [ -f "$file" ] && grep $plugin "$file" > /dev/null; then
    sed -i -e "s/$plugin .*/$plugin $version/" "$file"
  else
    echo "$plugin $version" >> "$file"
  fi
}

local_command() {
  version_command "local" $@
}

global_command() {
  version_command "global" $@
}
