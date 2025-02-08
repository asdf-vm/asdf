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
  cmd2=${COMP_WORDS[2]}
  cmd3=${COMP_WORDS[3]}
  local prev
  prev=${COMP_WORDS[COMP_CWORD - 1]}
  local plugins
  plugins=$(asdf plugin list 2>/dev/null | tr '\n' ' ')

  # We can safely ignore warning SC2207 since it warns that it will uses the
  # shell's sloppy word splitting and globbing. The possible commands here are
  # all single words, and most likely won't contain special chars the shell will
  # expand.
  COMPREPLY=()

  case "$cmd" in
  plugin)
    case "$cmd2" in
    update)
      # shellcheck disable=SC2207
      COMPREPLY=($(compgen -W "$plugins --all" -- "$cur"))
      ;;
    remove)
      # shellcheck disable=SC2207
      COMPREPLY=($(compgen -W "$plugins" -- "$cur"))
      ;;
    add)
      local available_plugins
      available_plugins=$(asdf plugin list all 2>/dev/null | awk '{ if ($2 !~ /^\*/) print $1}')
      # shellcheck disable=SC2207
      COMPREPLY=($(compgen -W "$available_plugins" -- "$cur"))
      ;;
    list)
      case "$cmd3" in
      all) ;;
      *)
        local cmds='all --urls --refs'
        # shellcheck disable=SC2207
        COMPREPLY=($(compgen -W "$cmds" -- "$cur"))
        ;;
      esac
      ;;
    *)
      local cmds='add list remove update'
      # shellcheck disable=SC2207
      COMPREPLY=($(compgen -W "$cmds" -- "$cur"))
      ;;
    esac
    ;;
  list)
    if [[ " $plugins " == *" $prev "* ]]; then
      local versions
      versions=$(asdf list all "$prev" 2>/dev/null)
      # shellcheck disable=SC2207
      COMPREPLY=($(compgen -W "$versions" -- "$cur"))
    else
      case "$cmd2" in
      all)
        # shellcheck disable=SC2207
        COMPREPLY=($(compgen -W "$plugins" -- "$cur"))
        ;;
      *)
        # shellcheck disable=SC2207
        COMPREPLY=($(compgen -W "$plugins all" -- "$cur"))
        ;;
      esac
    fi
    ;;
  install | help)
    if [[ " $plugins " == *" $prev "* ]]; then
      local versions
      versions=$(asdf list all "$prev" 2>/dev/null)
      # shellcheck disable=SC2207
      COMPREPLY=($(compgen -W "$versions" -- "$cur"))
    else
      # shellcheck disable=SC2207
      COMPREPLY=($(compgen -W "$plugins" -- "$cur"))
    fi
    ;;
  uninstall | where | reshim)
    if [[ " $plugins " == *" $prev "* ]]; then
      local versions
      # The first two columns are either blank or contain the "current" marker.
      versions=$(asdf list "$prev" 2>/dev/null | colrm 1 2)
      # shellcheck disable=SC2207
      COMPREPLY=($(compgen -W "$versions" -- "$cur"))
    else
      # shellcheck disable=SC2207
      COMPREPLY=($(compgen -W "$plugins" -- "$cur"))
    fi
    ;;
  set)
    if [[ " $plugins " == *" $prev "* ]]; then
      local versions
      # The first two columns are either blank or contain the "current" marker.
      versions=$(asdf list "$prev" 2>/dev/null | colrm 1 2)
      versions+=" system"
      # shellcheck disable=SC2207
      COMPREPLY=($(compgen -W "$versions" -- "$cur"))
    else
      # shellcheck disable=SC2207
      COMPREPLY=($(compgen -W "$plugins -u -p" -- "$cur"))
    fi
    ;;
  latest)
    if [[ " $plugins " == *" $prev "* ]]; then
      local versions
      versions=$(asdf list all "$prev" 2>/dev/null)
      # shellcheck disable=SC2207
      COMPREPLY=($(compgen -W "$versions" -- "$cur"))
    else
      # shellcheck disable=SC2207
      COMPREPLY=($(compgen -W "$plugins --all" -- "$cur"))
    fi
    ;;
  exec | env | which | shimversions)
    # shellcheck disable=SC2207
    COMPREPLY=($(compgen -W "$(_asdf_list_shims)" -- "$cur"))
    ;;
  current)
    # shellcheck disable=SC2207
    COMPREPLY=($(compgen -W "$plugins" -- "$cur"))
    ;;
  info) ;;
  *)
    local cmds='current set help install latest list plugin reshim shimversions uninstall where which exec env info'
    # shellcheck disable=SC2207
    COMPREPLY=($(compgen -W "$cmds" -- "$cur"))
    ;;
  esac

  return 0
}

complete -F _asdf asdf
