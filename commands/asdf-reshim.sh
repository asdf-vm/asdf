source $(dirname $(dirname $0))/lib/utils.sh


ensure_shims_dir() {
  # Create shims dir if doesn't exist
  if [ ! -d $(asdf_dir)/shims ]
    then
    mkdir $(asdf_dir)/shims
  fi
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



package=$1
full_version=$2
source_path=$(get_source_path $package)
check_if_source_exists $source_path
ensure_shims_dir

# If full version is empty then generate shims for all versions in the package
if [ $full_version = "" ]
then
  for install in ${package_installs_path}/*/; do
    full_version_name=$(echo $(basename $install) | sed 's/tag\-/tag\:/' | sed 's/commit-/commit:/')
    generate_shims_for_version $package $full_version_name
  done
else
  generate_shims_for_version $package $full_version
fi
