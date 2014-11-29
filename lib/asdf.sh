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
  check_and_run "list-all" $1 list_all_command "${@:2}"

  # if [ "$1" = "list" ]
  # then
  #   list_command "$@"
  #   exit 0
  # fi


  help_all
}


list_all_command() {
  asdf_path=$(asdf_dir)
  if [ -d ${asdf_path}/sources/$1 ]
    then
    echo ./$(asdf_dir)/sources/$1/list-all
  else
    display_error "no such package"
  fi
}


list_command() {
  asdf_path=$(asdf_dir)
  if [ -d ${asdf_path}/sources/$1 ]
  then
    # echo ./$(asdf_dir)/sources/$1/list
    #TODO list versions installed with the installs/erlang/.installs file
    # the .installs file will have lines of the format "version hash"
  else
    display_error "no such package"
  fi
}

display_error() {
  echo $1
}

help_all() {
  echo "display help message"
}
