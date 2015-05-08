exec_command() {
  local package=$1
  local executable_path=$2


  #TODO support .versions file
  local full_version=$ASDF_PACKAGE_VERSION

  local source_path=$(get_source_path $package)
  check_if_source_exists $source_path

  IFS=':' read -a version_info <<< "$full_version"
  if [ "${version_info[0]}" = "tag" ] || [ "${version_info[0]}" = "commit" ]
    then
    local install_type="${version_info[0]}"
    local version="${version_info[1]}"
  else
    local install_type="version"
    local version="${version_info[0]}"
  fi


  local install_path=$(get_install_path $package $install_type $version)


  if [ -f ${source_path}/bin/exec-env ]
  then
    local exec_env=$(${source_path}/bin/exec-env $install_type $version $install_path)
    eval $exec_env ${install_path}/${executable_path} ${@:3}
  else
    ${install_path}/${executable_path} ${@:3}
  fi
}


reshim_command() {
  local package=$1
  local version=$2

  local source_path=$(get_source_path $package)
  check_if_source_exists $source_path


  if [ ! -d $(asdf_dir)/shims ]
    then
    mkdir $(asdf_dir)/shims
  fi


  local package_installs_path=$(asdf_dir)/installs/${package}

  if [ $version = "" ]
  then
    #TODO add support to parse "tag-$version" dir names to what we want
    for install in ${package_installs_path}/*/; do
      echo "TODO"
      echo "$(basename $install)"
    done
  else
    generate_shims_for_version $package $version "${@:3}"
  fi
}
