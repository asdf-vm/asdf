#!/usr/bin/env sh

#TODO run command with args

#TODO decide which function to run based on args

ASDF_DIR=$(dirname $0)

asdf_version() {
  echo "0.1"
}


asdf_dir() {
  echo $(dirname $(dirname $0))
}


check_and_run() {
  if [ "$1" = "$2" ]
  then
    $($3 ${@:4})
    exit 0
  fi
}


run_command() {
  check_and_run "--version" $1 asdf_version "${@:2}"
  check_and_run "list" $1 list_command "${@:2}"

  # if [ "$1" = "list" ]
  # then
  #   list_command "$@"
  #   exit 0
  # fi


  help_all
}



list_command() {
  echo ./$(asdf_dir)/sources/$1/list
}

help_all() {
  echo "display help message"
}

run_command "$@"
