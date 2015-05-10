asdf_version() {
  echo "0.1"
}


asdf_dir() {
  if [ -z $ASDF_DIR ]
  then
    export ASDF_DIR=$(cd $(dirname $(dirname $0)); echo $(pwd))
  fi

  echo $ASDF_DIR
}


run_callback_if_command() {
  if [ "$1" = "$2" ]
    then
    $3 ${@:4}
    exit 0
  fi
}


list_package_installs() {
  local package=$1
  local package_installs_path=$(asdf_dir)/installs/${package}

  if [ -d $package_installs_path ]
  then
    #TODO check if dir is empty and show message here too
    for install in ${package_installs_path}/*/; do
      echo "$(basename $install)"
    done
  else
    echo 'Oohes nooes ~! Nothing found'
  fi
}


get_install_path() {
  local package=$1
  local install_type=$2
  local version=$3
  mkdir -p $(asdf_dir)/installs/${package}

  if [ $install_type = "version" ]
  then
    echo $(asdf_dir)/installs/${package}/${version}
  else
    echo $(asdf_dir)/installs/${package}/${install_type}-${version}
  fi
}


check_if_source_exists() {
  if [ ! -d $1 ]
    then
    display_error "No such package"
    exit 1
  fi
}


get_version_part() {
  IFS='@' read -a version_info <<< "$1"
  echo ${version_info[$2]}
}


get_source_path() {
  echo $(asdf_dir)/sources/$1
}


write_shim_script() {
  local package=$1
  local version=$2
  local executable_path=$3
  local shim_path=$(asdf_dir)/shims/$(basename $executable_path)

  echo """#!/usr/bin/env sh
asdf exec ${package} $executable_path \${@:1}
""" > $shim_path

  chmod +x $shim_path
}


generate_shims_for_version() {
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

  local space_seperated_list_of_executables=$(sh ${source_path}/bin/list-executables $package $install_type $version "${@:2}")
  IFS=' ' read -a all_executables <<< "$space_seperated_list_of_executables"

  for executable in "${all_executables[@]}"
  do
    write_shim_script $package $version $executable
  done
}


display_error() {
  echo $1
}
