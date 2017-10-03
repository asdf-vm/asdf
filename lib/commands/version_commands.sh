version_command() {
  local cmd=$1
  local plugin=$2

  if [ "$#" -lt "3" ]; then
    echo "Usage: asdf $cmd <name> <version>"
    exit 1
  fi

  shift 2
  local versions=("$@")

  local file
  if [ "$cmd" = "global" ]; then
    file="$HOME/.tool-versions"
  else
    file="$(pwd)/.tool-versions"
  fi

  check_if_plugin_exists "$plugin"

  local version
  for version in "${versions[@]}"; do
    check_if_version_exists "$plugin" "$version"
  done

  if [ -f "$file" ] && grep "$plugin" "$file" > /dev/null; then
    sed -i -e "s/$plugin .*/$plugin ${versions[*]}/" "$file"
  else
    echo "$plugin ${versions[*]}" >> "$file"
  fi
}

local_command() {
  # shellcheck disable=2068
  version_command "local" $@
}

global_command() {
  # shellcheck disable=2068
  version_command "global" $@
}
