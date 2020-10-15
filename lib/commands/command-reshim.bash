# -*- sh -*-

set -o nounset

# shellcheck source=lib/commands/reshim.bash
. "$(dirname "$ASDF_CMD_FILE")/reshim.bash"

reshim_command "$@"
