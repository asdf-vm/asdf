# -*- sh -*-
# shellcheck source=lib/functions/versions.bash
. "$(dirname "$(dirname "$0")")/lib/functions/versions.bash"
# shellcheck source=lib/commands/reshim.bash
. "$(dirname "$ASDF_CMD_FILE")/reshim.bash"
# shellcheck source=lib/functions/installs.bash
. "$(dirname "$(dirname "$0")")/lib/functions/installs.bash"

install_command "$@"
