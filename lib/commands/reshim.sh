shim_command() {
  local plugin_name=$1
  local executable_path=$2
  local plugin_path=$(get_plugin_path $plugin_name)
  check_if_plugin_exists $plugin_path
  ensure_shims_dir

  generate_shim_for_executable $plugin_name $executable_path
}

reshim_command() {
  local plugin_name=$1
  local full_version=$2
  local plugin_path=$(get_plugin_path $plugin_name)
  check_if_plugin_exists $plugin_path
  ensure_shims_dir

  if [ "$full_version" != "" ]; then
    # generate for the whole package version
    generate_shims_for_version $plugin_name $full_version
  else
    # generate for all versions of the package
    local plugin_installs_path=$(asdf_dir)/installs/${plugin_name}

    for install in ${plugin_installs_path}/*/; do
      local full_version_name=$(echo $(basename $install) | sed 's/ref\-/ref\:/')
      generate_shims_for_version $plugin_name $full_version_name
    done
  fi
}


ensure_shims_dir() {
  # Create shims dir if doesn't exist
  if [ ! -d $(asdf_dir)/shims ]; then
    mkdir $(asdf_dir)/shims
  fi
}


write_shim_script() {
  local plugin_name=$1
  local executable_path=$2
  local executable_name=$(basename $executable_path)
  local plugin_shims_path=$(get_plugin_path $plugin_name)/shims
  local shim_path=$(asdf_dir)/shims/$executable_name

  if [ -f $plugin_shims_path/$executable_name ]; then
    cp $plugin_shims_path/$executable_name $shim_path
  else
    echo """#!/usr/bin/env bash
exec $(asdf_dir)/bin/private/asdf-exec ${plugin_name} ${executable_path} \"\$@\"
""" > $shim_path
  fi

  chmod +x $shim_path
}


generate_shim_for_executable() {
  local plugin_name=$1
  local executable=$2
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

  write_shim_script $plugin_name $executable
}


generate_shims_for_version() {
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

  if [ -f ${plugin_path}/bin/list-bin-paths ]; then
    local space_seperated_list_of_bin_paths=$(
      export ASDF_INSTALL_TYPE=$install_type
      export ASDF_INSTALL_VERSION=$version
      export ASDF_INSTALL_PATH=$install_path
      bash ${plugin_path}/bin/list-bin-paths
    )
  else
    local space_seperated_list_of_bin_paths="bin"
  fi

  IFS=' ' read -a all_bin_paths <<< "$space_seperated_list_of_bin_paths"

  for bin_path in "${all_bin_paths[@]}"; do
    for executable_file in $install_path/$bin_path/*; do
      # because just $executable_file gives absolute path; We don't want version hardcoded in shim
      local executable_path_relative_to_install_path=$bin_path/$(basename $executable_file)
      if [ -x $executable_path_relative_to_install_path ]; then
          write_shim_script $plugin_name $executable_path_relative_to_install_path
      fi
    done
  done
}
