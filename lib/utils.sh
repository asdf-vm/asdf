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


get_asdf_versions_file_path() {
  if [ -f $(pwd)/.asdf-versions ]; then
    echo $(pwd)/.asdf-versions
  elif [ -f $HOME/.asdf-versions ]; then
    echo $HOME/.asdf-versions
  else
    touch $HOME/.asdf_versions
    echo $HOME/.asdf-versions
  fi
}


get_preset_version_for() {
  local package=$1
  local asdf_versions_path=$(get_asdf_versions_file_path)

  while read tool_line
  do
    IFS=' ' read -a tool_info <<< $tool_line
    local tool_name=$(echo -e "${tool_info[0]}" | xargs)
    local tool_version=$(echo -e "${tool_info[1]}" | xargs)

    if [ $tool_name = "$package" ]; then
      echo $tool_version
      break;
    fi
  done < $asdf_versions_path

  # our way of saying no version found
  echo ""
}
