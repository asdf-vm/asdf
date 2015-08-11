install_command() {
  local plugin_name=$1
  local full_version=$2

  if [ "$plugin_name" = "" ] && [ "$full_version" = "" ]; then
    install_local_tool_versions
  else
    install_tool_version $plugin_name $full_version
  fi
}


install_local_tool_versions() {
  if [ -f $(pwd)/.tool-versions ]; then
    local asdf_versions_path=$(pwd)/.tool-versions

    local read_done=false
    until $read_done; do
      read tool_line || read_done=true

      if $read_done ; then
        break;
      fi

      IFS=' ' read -a tool_info <<< $tool_line
      local t_name=$(echo "${tool_info[0]}" | xargs)
      local t_version=$(echo "${tool_info[1]}" | xargs)

      install_command $t_name $t_version
    done < $asdf_versions_path
  else
    echo "Either specify a tool & version in the command"
    echo "OR add .tool-versions file in this directory"
    exit 1
  fi
}


install_tool_version() {
  local plugin_name=$1
  local full_version=$2
  local plugin_path=$(get_plugin_path $plugin_name)
  check_if_plugin_exists $plugin_path


  IFS=':' read -a version_info <<< "$full_version"
  if [ "${version_info[0]}" = "ref" ]; then
    local install_type="${version_info[0]}"
    local version="${version_info[1]}"
  else
    local install_type="version"
    local version="${version_info[0]}"
  fi


  local install_path=$(get_install_path $plugin_name $install_type $version)
  if [ -d $install_path ]; then
    echo "$plugin_name $full_version is already installed"
  else
    (
      export ASDF_INSTALL_TYPE=$install_type
      export ASDF_INSTALL_VERSION=$version
      export ASDF_INSTALL_PATH=$install_path
      mkdir $install_path
      bash ${plugin_path}/bin/install
    )

    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
      reshim_command $plugin_name $full_version
    else
      rm -rf $install_path
      exit 1
    fi
  fi
}
