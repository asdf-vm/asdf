# -*- sh -*-

# shellcheck source=lib/commands/version_commands.bash
. "$(dirname "$ASDF_CMD_FILE")/version_commands.bash"

local_command() {
  local parent=false
  local positional=()

  while [[ $# -gt 0 ]]; do
    case $1 in
    -p | --parent)
      parent="true"
      shift # past value
      ;;
    *)
      positional+=("$1") # save it in an array for later
      shift              # past argument
      ;;
    esac
  done

  set -- "${positional[@]}" # restore positional parameters

  if [ $parent = true ]; then
    version_command local-tree "$@"
  else
    version_command local "$@"
  fi
}

local_command "$@"
