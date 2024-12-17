# -*- sh -*-

update_command() {
  printf "Upgrading asdf via asdf update is no longer supported. Please use your OS\npackage manager (Homebrew, APT, etc...) to upgrade asdf or download the\nlatest asdf binary manually from the asdf website.\n\nPlease visit https://asdf-vm.com/ or https://github.com/asdf-vm/asdf for more\ndetails.\n"

  exit 1
}

update_command "$@"
