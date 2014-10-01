help_install () {
  echo "asdf install <package> <version>"
  echo "\tInstall the specified version of the package"
}

help_uninstall () {
  echo "asdf uninstall <package> <version>"
  echo "\tUninstall the specified version of the package"
}

help_installed () {
  echo "asdf installed <package>"
  echo "\tList the installed versions of the package"
}

help_available () {
  echo "asdf available <package>"
  echo "\tList all the available versions of the package"
}

help_use () {
  echo "asdf use <package> <version>"
  echo "\tUse the specified version of the package for the current shell environment"
}

help_source_add () {
  echo "asdf source add <package> <repo>"
  echo "\tAdd the git repo as the source for the package"
}

help_source_remove () {
  echo "asdf source remove <package>"
  echo "\tRemove the source for the package"
}

help_source_update () {
  echo "asdf source update <package>"
  echo "\tUpdate the package's source"
}

help_source_update_all () {
  echo "asdf source update --all"
  echo "\tUpdate the sources of all packages"
}

help_help () {
  echo "asdf help"
  echo "\tDisplay this help message"
}


help_all () {
  commands_to_run=(
    help_install
    help_uninstall
    help_installed
    help_available
    help_use
    help_source_add
    help_source_remove
    help_source_update
    help_source_update_all
    help_help
  )

  echo "version: $(asdf_version)"
  echo

  for command in "${commands_to_run[@]}"
  do
    eval $command
    echo
  done
}
