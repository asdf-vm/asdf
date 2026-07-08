asdf_data_dir() {
  local data_dir

  if [ -n "${ASDF_DATA_DIR}" ]; then
    data_dir="${ASDF_DATA_DIR}"
  elif [ -n "$HOME" ]; then
    data_dir="$HOME/.asdf"
  else
    data_dir=$(asdf_dir)
  fi

  printf "%s\n" "$data_dir"
}

asdf_dir() {
  if [ -z "$ASDF_DIR" ]; then
    local current_script_path=${BASH_SOURCE[0]}
    printf '%s\n' "$(
      cd -- "$(dirname "$(dirname "$current_script_path")")" || exit
      printf '%s\n' "$PWD"
    )"
  else
    printf '%s\n' "$ASDF_DIR"
  fi
}

get_plugin_path() {
  if [ -n "$1" ]; then
    printf "%s\n" "$(asdf_data_dir)/plugins/$1"
  else
    printf "%s\n" "$(asdf_data_dir)/plugins"
  fi
}
