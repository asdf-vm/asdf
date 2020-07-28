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
  local plugin_name="$1"
  local tool_version="$2"
  local plugin_path

  # If plugin name is present as first argument output plugin help info
  if [ -n "$plugin_name" ]; then
    plugin_path=$(get_plugin_path "$plugin_name")

    if [ -d "$plugin_path" ]; then
      if [ -f "${plugin_path}/bin/help.overview" ]; then
        if [ -n "$tool_version" ]; then

          # TODO: Refactor this code out into helper functions in utils.bash
          IFS=':' read -r -a version_info <<<"$tool_version"
          if [ "${version_info[0]}" = "ref" ]; then
            local install_type="${version_info[0]}"
            local version="${version_info[1]}"
          else
            local install_type="version"

            if [ "${version_info[0]}" = "latest" ]; then
              local version
              version=$(asdf latest "$plugin_name" "${version_info[1]}")
            else
              local version="${version_info[0]}"
            fi
          fi

          local install_path
          install_path=$(get_install_path "$plugin_name" "$install_type" "$version")

          (
            # shellcheck disable=SC2031
            export ASDF_INSTALL_TYPE=$install_type
            # shellcheck disable=SC2031
            export ASDF_INSTALL_VERSION=$version
            # shellcheck disable=SC2031
            export ASDF_INSTALL_PATH=$install_path

            print_plugin_help "$plugin_path"
          )
        else
          (print_plugin_help "$plugin_path")
        fi
      else
        echo "No documentation for plugin $plugin_name" >&2
        exit 1
      fi
    else
      echo "No plugin named $plugin_name" >&2
      exit 1
    fi
  else
    # Otherwise output general asdf help
    asdf_help
    asdf_extension_cmds
    asdf_moto
  fi
}

print_plugin_help() {
  local plugin_path=$1

  # Eventually @jthegedus or someone else will format the output from these
  # scripts in a certain way.
  bash "${plugin_path}"/bin/help.overview

  if [ -f "${plugin_path}"/bin/help.deps ]; then
    bash "${plugin_path}"/bin/help.deps
  fi

  if [ -f "${plugin_path}"/bin/help.config ]; then
    bash "${plugin_path}"/bin/help.config
  fi

  if [ -f "${plugin_path}"/bin/help.links ]; then
    bash "${plugin_path}"/bin/help.links
  fi
}

help_command "$@"
