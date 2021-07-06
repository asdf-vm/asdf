# -*- sh -*-

# shellcheck source=lib/commands/version_commands.bash
. "$(dirname "$ASDF_CMD_FILE")/version_commands.bash"
version_command global "$@"
