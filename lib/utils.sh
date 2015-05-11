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


display_error() {
  echo $1
}
