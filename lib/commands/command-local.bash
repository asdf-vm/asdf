# -*- sh -*-

# shellcheck source=lib/commands/version_commands.bash
. "$(dirname "$ASDF_CMD_FILE")/version_commands.bash"
# shellcheck source=lib/commands/reshim.bash
. "$(dirname "$ASDF_CMD_FILE")/reshim.bash"
# shellcheck source=lib/functions/installs.bash
. "$(dirname "$(dirname "$0")")/lib/functions/installs.bash"

local_command "$@"
