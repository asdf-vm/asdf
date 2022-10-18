# -*- sh -*-
# shellcheck source=lib/functions/plugins.bash
. "$(dirname "$(dirname "$0")")/functions/plugins.bash"

plugin_add_command "$@"
