asdf_version() {
  echo "0.2.0-dev"
}


asdf_dir() {
  if [ -z $ASDF_DIR ]; then
    local current_script_path=${BASH_SOURCE[0]}
    export ASDF_DIR=$(cd $(dirname $(dirname $current_script_path)); echo $(pwd))
  fi

  echo $ASDF_DIR
}


get_install_path() {
  local plugin=$1
  local install_type=$2
  local version=$3
  mkdir -p $(asdf_dir)/installs/${plugin}

  if [ $install_type = "version" ]
  then
    echo $(asdf_dir)/installs/${plugin}/${version}
  else
    echo $(asdf_dir)/installs/${plugin}/${install_type}-${version}
  fi
}


check_if_plugin_exists() {
  # Check if we have a non-empty argument
  if [ -z "${1+set}" ]; then
    display_error "No such plugin"
    exit 1
  fi

  if [ ! -d $(asdf_dir)/plugins/$1 ]; then
    display_error "No such plugin"
    exit 1
  fi
}

check_if_version_exists() {
  local plugin=$1
  local version=$2
  local version_dir=$(asdf_dir)/installs/$plugin/$version
  if [ ! -d $version_dir ]; then
    display_error "version $version is not installed for $plugin"
    exit 1
  fi
}


get_version_part() {
  IFS='@' read -a version_info <<< "$1"
  echo ${version_info[$2]}
}


get_plugin_path() {
  echo $(asdf_dir)/plugins/$1
}


display_error() {
  echo >&2 $1
}

find_version_file_for() {
  local plugin_name=$1

  local plugin_path=$(get_plugin_path "$plugin_name")
  local legacy_config=$(get_asdf_config_value "legacy_version_file")
  local legacy_list_filenames_script="${plugin_path}/bin/list-legacy-filenames"
  local search_path=$(pwd)

  if [ "$legacy_config" = "yes" ] && [ -f $legacy_list_filenames_script ]; then
    local legacy_filenames=$(bash "$legacy_list_filenames_script")
    echo $(search_filenames ".tool-versions $legacy_filenames" "$search_path")
  else
    echo $(search_filenames ".tool-versions" "$search_path")
  fi
}

search_filenames() {
  local filenames=$1
  local search_path=$2

  while [ "$search_path" != "/" ]; do
    for filename in $filenames; do
      if [ -f "$search_path/$filename" ]; then
        echo "$search_path/$filename"
        return 0
      fi
    done
    search_path=$(dirname "$search_path")
  done
}

parse_asdf_version_file() {
  local file_path=$1
  local plugin_name=$2

  cat $file_path | while read -r line || [[ -n "$line" ]]; do
    local line_parts=($line)

    if [ "${line_parts[0]}" = "$plugin_name" ]; then
      echo ${line_parts[1]}
      return 0
    fi
  done
}

parse_legacy_version_file() {
  local file_path=$1
  local plugin_name=$2

  local plugin_path=$(get_plugin_path "$plugin_name")
  local parse_legacy_script="${plugin_path}/bin/parse-legacy-file"

  if [ -f $parse_legacy_script ]; then
    echo $(bash "$parse_legacy_script" "$file_path")
  else
    echo $(cat $file_path)
  fi
}

parse_version_file() {
  local file_path=$1
  local plugin_name=$2

  if [ $(basename $file_path) = ".tool-versions" ]; then
    echo $(parse_asdf_version_file "$file_path" "$plugin_name")
  else
    echo $(parse_legacy_version_file "$file_path" "$plugin_name")
  fi
}

get_preset_version_for() {
  local plugin_name=$1
  local version_file_path=$(find_version_file_for "$plugin_name")
  echo $(parse_version_file "$version_file_path" "$plugin_name")
}

get_asdf_config_value_from_file() {
    local config_path=$1
    local key=$2

    if [ ! -f $config_path ]; then
        return 0
    fi

    local result=$(grep -E "^\s*$key\s*=" $config_path | awk -F '=' '{ gsub(/ /, "", $2); print $2 }')
    if [ -n "$result" ]; then
        echo $result
    fi
}

get_asdf_config_value() {
    local key=$1
    local config_path=${AZDF_CONFIG_FILE:-"$HOME/.asdfrc"}
    local default_config_path=${AZDF_CONFIG_DEFAULT_FILE:-"$(asdf_dir)/defaults"}

    local result=$(get_asdf_config_value_from_file $config_path $key)

    if [ -n "$result" ]; then
        echo $result
    else
        get_asdf_config_value_from_file $default_config_path $key
    fi
}
