run_command() {
  local callback_args="${@:2}"
  run_callback_if_command "--version" $1 asdf_version       $callback_args
  run_callback_if_command "install"   $1 install_command    $callback_args
  run_callback_if_command "uninstall" $1 uninstall_command  $callback_args
  run_callback_if_command "list"      $1 list_command       $callback_args
  run_callback_if_command "list-all"  $1 list_all_command   $callback_args

  run_callback_if_command "add-source"     $1 source_add_command     $callback_args
  run_callback_if_command "remove-source"  $1 source_remove_command  $callback_args
  run_callback_if_command "update-source"  $1 source_update_command  $callback_args

  run_callback_if_command "reshim" $1 reshim_command $callback_args

  run_callback_if_command "exec"   $1 exec_command $callback_args
  run_callback_if_command "help"   $1 help_command $callback_args


  help_command
  exit 1
}

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


install_command() {
  local package=$1
  local full_version=$2
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
  ${source_path}/bin/install $install_type $version $install_path
  #TODO generate shims
}


uninstall_command() {
  local package=$1
  local full_version=$2
  local source_path=$(get_source_path $package)

  check_if_source_exists $source_path
  if [ ! -d "$source_path/$full_version" ]
  then
    display_error "No such version"
    exit 1
  fi

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

  if [ -f ${source_path}/bin/uninstall ]
  then
    ${source_path}/bin/uninstall $install_type $version $install_path "${@:3}"
  else
    rm -rf $install_path
  fi
}


list_all_command() {
  local source_path=$(get_source_path $1)
  check_if_source_exists $source_path
  local versions=$( ${source_path}/bin/list-all )

  IFS=' ' read -a versions_list <<< "$versions"

  for version in "${versions_list[@]}"
  do
    echo "${version}"
  done
}


list_command() {
  local source_path=$(get_source_path $1)
  check_if_source_exists $source_path
  list_package_installs $1
}


source_add_command() {
  local package_name=$1
  local source_url=$2
  local source_path=$(get_source_path $package_name)

  mkdir -p $(asdf_dir)/sources
  git clone $source_url $source_path
  if [ $? -eq 0 ]
  then
    chmod +x $source_path/bin/*
  fi
}


source_remove_command() {
  local package_name=$1
  local source_path=$(get_source_path $package_name)

  rm -rf $source_path
  rm -rf $(asdf_dir)/installs/${package_name}
}


source_update_command() {
  local package_name=$1
  if [ "$package_name" = "--all" ]
  then
    for dir in $(asdf_dir)/sources/*; do (cd "$dir" && git pull); done
  else
    local source_path=$(get_source_path $package_name)
    check_if_source_exists $source_path
    (cd $source_path; git pull)
  fi
}


help_command() {
  echo "display help message"
}
