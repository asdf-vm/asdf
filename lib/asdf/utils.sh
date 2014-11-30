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


generate_random_hash() {
  openssl rand -hex 4
}


run_callback_if_command() {
  if [ "$1" = "$2" ]
    then
    $3 ${@:4}
    exit 0
  fi
}


check_if_source_exists() {
  if [ ! -d $1 ]
    then
    display_error "No such package"
    exit 1
  fi
}


get_source_path() {
  echo $(asdf_dir)/sources/$1
}


display_error() {
  echo $1
}
