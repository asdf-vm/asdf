# -*- sh -*-
# shellcheck source=lib/functions/plugins.bash
. "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")/lib/functions/plugins.bash"

plugin_update_command "$@"
