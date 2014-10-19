#!/usr/bin/env sh

#TODO run command with args

#TODO decide which function to run based on args

ASDF_DIR=$(dirname $0)

asdf_version () {
  echo "0.1"
}

run_command () {

  if [ $1 = "--version" ]
  then
    echo $(asdf_version)
    exit 0
  fi


  if [ $1 = "install" ]
  then
    install_command
    exit 0
  fi


  if [ $1 = "uninstall" ]
  then
    uninstall_command
    exit 0
  fi


  if [ $1 = "installed" ]
  then
    installed_command
    exit 0
  fi

  if [ $1 = "available" ]
  then
    available_command
    exit 0
  fi


  if [ $1 = "use" ]
  then
    use_command
    exit 0
  fi


  if [ $1 = "source" ]
  then
    source_command
    exit 0
  fi

  help_all
}


# # install <package> <version>
install_command() {
  echo "TODO install"
}

# uninstall_command <package> <version>
uninstall_command() {
  echo "TODO uninstall"
}

# # list
# list_packages_command() {
# }
#
#
# # list <package>
# list_all_versions_command() {
# }
#
#
# # list <package>
# list_installed_versions_command() {
# }
#
#
# # add <package> <source>
# # source can be username/repo got GitHub or full git url
# add_package_command() {
# }
#
#
# # use <package> <version>
# use_command() {
# }


# --help or help
# help_command {
# }


#### Private functions

# read_action_script() {
#
# }
#
# run_install_script() {
#
# }
#
# run_uninstall_script() {
#
# }

clone_git_repo() {
  git clone $2 $ASDF_DIR/sources/$1
}

clone_github_repo() {
  git clone https://github.com/$2 $ASDF_DIR/sources/$1
}


# check if package source dir has proper format. if no delete it
# verify_package_source() {
#
# }
