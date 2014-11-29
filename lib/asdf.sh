#!/usr/bin/env sh

#TODO run command with args

#TODO decide which function to run based on args

ASDF_DIR=$(dirname $0)

run_command() {
  run_callback_if_command "--version" $1 asdf_version     "${@:2}"
  run_callback_if_command "install"   $1 install_command  "${@:2}"
  run_callback_if_command "list"      $1 list_command     "${@:2}"
  run_callback_if_command "list-all"  $1 list_all_command "${@:2}"
  run_callback_if_command "help"      $1 help_command     "${@:2}"


  help_command
  exit 1
}


install_command() {
  local source_path=$(get_source_path $1)
  check_if_source_exists $source_path
  echo "TODO"
}



list_all_command() {
  local source_path=$(get_source_path $1)
  check_if_source_exists $source_path
  ./${source_path}/list-all
}


list_command() {
  local source_path=$(get_source_path $1)
  check_if_source_exists $source_path
  echo "TODO"
  # echo ./$(asdf_dir)/sources/$1/list
  #TODO list versions installed with the installs/erlang/.installs file
  # the .installs file will have lines of the format "version hash"
}


help_command() {
  echo "display help message"
}
