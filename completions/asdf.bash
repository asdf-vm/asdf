_asdf_list_shims() (
  # this function runs in a subshell so shopt is scoped
  shopt -s nullglob # globs that don't match should disappear
  shopt -u failglob # globs that don't match shouldn't fail
  for shim in "${ASDF_DATA_DIR:-$HOME/.asdf}"/shims/*; do
    basename "$shim"
  done
)

_asdf() {
  local cur
  cur=${COMP_WORDS[COMP_CWORD]}
  local cmd
  cmd=${COMP_WORDS[1]}
  local prev
  prev=${COMP_WORDS[COMP_CWORD - 1]}
  local plugins
  plugins=$(asdf plugin-list 2>/dev/null | tr '\n' ' ')

  # We can safely ignore warning SC2207 since it warns that it will uses the
  # shell's sloppy word splitting and globbing. The possible commands here are
  # all single words, and most likely won't contain special chars the shell will
  # expand.
  COMPREPLY=()

  case "$cmd" in
  plugin-update)
    # shellcheck disable=SC2207
    COMPREPLY=($(compgen -W "$plugins --all" -- "$cur"))
    ;;
  plugin-remove | current)
    # shellcheck disable=SC2207
    COMPREPLY=($(compgen -W "$plugins" -- "$cur"))
    ;;
  plugin-add)
    local available_plugins
    available_plugins=$(asdf plugin-list-all 2>/dev/null | awk '{ if ($2 !~ /^\*/) print $1}')
    # shellcheck disable=SC2207
    COMPREPLY=($(compgen -W "$available_plugins" -- "$cur"))
    ;;
  install | list | list-all | help)
    if [[ "$plugins" == *"$prev"* ]]; then
      local versions
      versions=$(asdf list-all "$prev" 2>/dev/null)
      # shellcheck disable=SC2207
      COMPREPLY=($(compgen -W "$versions" -- "$cur"))
    else
      # shellcheck disable=SC2207
      COMPREPLY=($(compgen -W "$plugins" -- "$cur"))
    fi
    ;;
  update)
    # shellcheck disable=SC2207
    COMPREPLY=($(compgen -W "--head" -- "$cur"))
    ;;
  uninstall | where | reshim)
    if [[ "$plugins" == *"$prev"* ]]; then
      local versions
      versions=$(asdf list "$prev" 2>/dev/null)
      # shellcheck disable=SC2207
      COMPREPLY=($(compgen -W "$versions" -- "$cur"))
    else
      # shellcheck disable=SC2207
      COMPREPLY=($(compgen -W "$plugins" -- "$cur"))
    fi
    ;;
  local | global | shell)
    if [[ "$plugins" == *"$prev"* ]]; then
      local versions
      versions=$(asdf list "$prev" 2>/dev/null)
      versions+=" system"
      # shellcheck disable=SC2207
      COMPREPLY=($(compgen -W "$versions" -- "$cur"))
    else
      # shellcheck disable=SC2207
      COMPREPLY=($(compgen -W "$plugins" -- "$cur"))
    fi
    ;;
  latest)
    # shellcheck disable=SC2207
    COMPREPLY=($(compgen -W "--all" -- "$cur"))
    ;;
  which | shim-versions)
    # shellcheck disable=SC2207
    COMPREPLY=($(compgen -W "$(_asdf_list_shims)" -- "$cur"))
    ;;
  plugin-list | plugin-list-all | info) ;;
  *)
    local cmds='current global help install latest list list-all local plugin-add plugin-list plugin-list-all plugin-remove plugin-update reshim shim-versions shell uninstall update where which info'
    # shellcheck disable=SC2207
    COMPREPLY=($(compgen -W "$cmds" -- "$cur"))
    ;;
  esac

  return 0
}

complete -F _asdf asdf
