# -*- sh -*-

asdf_help() {
  echo "version: $(asdf_version)"
  echo ""
  cat "$(asdf_dir)/help.txt"
}

asdf_moto() {
  cat <<EOF

"Late but latest"
-- Rajinikanth
EOF
}

asdf_extension_cmds() {
  local plugins_path ext_cmds plugin
  plugins_path="$(get_plugin_path)"
  # use find instead of ls -1
  # shellcheck disable=SC2012
  ext_cmds="$(ls -1 "$plugins_path"/*/lib/commands/command*.bash 2>/dev/null |
    sed "s#^$plugins_path/##;s#lib/commands/command##;s/.bash//;s/^-//;s/-/ /g")"
  if test -n "$ext_cmds"; then
    echo "$ext_cmds" | cut -d'/' -f 1 | uniq | while read -r plugin; do
      echo
      echo "PLUGIN $plugin"
      echo "$ext_cmds" | grep "$plugin/" | sed "s#^$plugin/#  asdf $plugin#" | sort
    done
  fi
}

help_command() {
  asdf_help
  asdf_extension_cmds
  asdf_moto
}

help_command "$@"
