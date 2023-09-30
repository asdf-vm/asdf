# -*- sh -*-
# shellcheck source=lib/functions/versions.bash
. "$(asdf_dir)/lib/functions/versions.bash"
# shellcheck source=lib/commands/reshim.bash
. "$(dirname "$ASDF_CMD_FILE")/reshim.bash"
# shellcheck source=lib/functions/installs.bash
. "$(asdf_dir)/lib/functions/installs.bash"

install_command "$@"
